# frozen_string_literal: true

require_relative 'conditions_extractor.rb'
require 'cancan/rules_compressor'
module CanCan
  module ModelAdapters
    class ActiveRecordAdapter < AbstractAdapter
      def self.version_greater_or_equal?(version)
        Gem::Version.new(ActiveRecord.version).release >= Gem::Version.new(version)
      end

      def self.version_lower?(version)
        Gem::Version.new(ActiveRecord.version).release < Gem::Version.new(version)
      end

      def initialize(model_class, rules)
        super
        @compressed_rules = RulesCompressor.new(@rules.reverse).rules_collapsed.reverse
        ConditionsNormalizer.normalize(model_class, @compressed_rules)
      end

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
        conditions_extractor = ConditionsExtractor.new(@model_class)
        if @compressed_rules.size == 1 && @compressed_rules.first.base_behavior
          # Return the conditions directly if there's just one definition
          conditions_extractor.tableize_conditions(@compressed_rules.first.conditions).dup
        else
          extract_multiple_conditions(conditions_extractor, @compressed_rules)
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
          build_relation(conditions)
        else
          @model_class.all(conditions: conditions, joins: joins)
        end
      end

      # Returns the associations used in conditions for the :joins option of a search.
      # See ModelAdditions#accessible_by
      def joins
        joins_hash = {}
        @compressed_rules.reverse_each do |rule|
          deep_merge(joins_hash, rule.associations_hash)
        end
        deep_clean(joins_hash) unless joins_hash.empty?
      end

      private

      # Removes empty hashes and moves everything into arrays.
      def deep_clean(joins_hash)
        joins_hash.map { |name, nested| nested.empty? ? name : { name => deep_clean(nested) } }
      end

      # Takes two hashes and does a deep merge.
      def deep_merge(base_hash, added_hash)
        added_hash.each do |key, value|
          if base_hash[key].is_a?(Hash)
            deep_merge(base_hash[key], value) unless value.empty?
          else
            base_hash[key] = value
          end
        end
      end

      def override_scope
        conditions = @compressed_rules.map(&:conditions).compact
        return unless conditions.any? { |c| c.is_a?(ActiveRecord::Relation) }
        return conditions.first if conditions.size == 1

        raise_override_scope_error
      end

      def raise_override_scope_error
        rule_found = @compressed_rules.detect { |rule| rule.conditions.is_a?(ActiveRecord::Relation) }
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
