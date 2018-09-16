require_relative 'can_can/model_adapters/active_record_adapter/joins.rb'
require_relative 'conditions_extractor.rb'
require 'cancan/rules_compressor'
module CanCan
  module ModelAdapters
    module ActiveRecordAdapter
      include CanCan::ModelAdapters::ActiveRecordAdapter::Joins

      # Returns conditions intended to be used inside a database query. Normally you will not call this
      # method directly, but instead go through ModelAdditions#accessible_by.
      #
      # If there is only one "can" definition, a hash of conditions will be returned matching the one defined.
      #
      #   can :manage, User, :id => 1
      #   query(:manage, User).conditions # => { :id => 1 }
      #
      # If there are multiple "can" definitions, a SQL string will be returned to handle complex cases.
      #
      #   can :manage, User, :id => 1
      #   can :manage, User, :manager_id => 1
      #   cannot :manage, User, :self_managed => true
      #   query(:manage, User).conditions # => "not (self_managed = 't') AND ((manager_id = 1) OR (id = 1))"
      #
      def conditions
        compressed_rules = RulesCompressor.new(@rules.reverse).rules_collapsed.reverse
        conditions_extractor = ConditionsExtractor.new(@model_class)
        if compressed_rules.size == 1 && compressed_rules.first.base_behavior
          # Return the conditions directly if there's just one definition
          conditions_extractor.tableize_conditions(compressed_rules.first.conditions).dup
        else
          extract_multiple_conditions(conditions_extractor, compressed_rules)
        end
      end

      def extract_multiple_conditions(conditions_extractor, rules)
        rules.reverse.inject(false_sql) do |sql, rule|
          merge_conditions(sql, conditions_extractor.tableize_conditions(rule.conditions).dup, rule.base_behavior)
        end
      end

      def database_records
        if override_scope
          @model_class.where(nil).merge(override_scope)
        elsif @model_class.respond_to?(:where) && @model_class.respond_to?(:joins)
          mergeable_conditions? ? build_relation(conditions) : build_relation(*@rules.map(&:conditions))
        else
          @model_class.all(conditions: conditions, joins: joins)
        end
      end

      private

      def mergeable_conditions?
        @rules.find(&:unmergeable?).blank?
      end

      def override_scope
        conditions = @rules.map(&:conditions).compact
        return unless conditions.any? { |c| c.is_a?(ActiveRecord::Relation) }
        return conditions.first if conditions.size == 1
        raise_override_scope_error
      end

      def raise_override_scope_error
        rule_found = @rules.detect { |rule| rule.conditions.is_a?(ActiveRecord::Relation) }
        raise Error,
              'Unable to merge an Active Record scope with other conditions. '\
              "Instead use a hash or SQL for #{rule_found.actions.first} #{rule_found.subjects.first} ability."
      end

      def merge_conditions(sql, conditions_hash, behavior)
        if conditions_hash.blank?
          behavior ? true_sql : false_sql
        else
          merge_non_empty_conditions(behavior, conditions_hash, sql)
        end
      end

      def merge_non_empty_conditions(behavior, conditions_hash, sql)
        conditions = sanitize_sql(conditions_hash)
        case sql
        when true_sql
          behavior ? true_sql : "not (#{conditions})"
        when false_sql
          behavior ? conditions : false_sql
        else
          behavior ? "(#{conditions}) OR (#{sql})" : "not (#{conditions}) AND (#{sql})"
        end
      end

      def false_sql
        sanitize_sql(['?=?', true, false])
      end

      def true_sql
        sanitize_sql(['?=?', true, true])
      end

      def sanitize_sql(conditions)
        @model_class.send(:sanitize_sql, conditions)
      end
    end
  end
end

ActiveSupport.on_load(:active_record) do
  send :include, CanCan::ModelAdditions
end
