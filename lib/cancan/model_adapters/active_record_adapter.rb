# frozen_string_literal: true

module CanCan
  module ModelAdapters
    class ActiveRecordAdapter < AbstractAdapter
      def self.for_class?(klass)
        klass < ActiveRecord::Base
      end

      def initialize(relation_or_class, rules)
        super
        @model_class = relation_or_class.respond_to?(:klass) ? relation_or_class.klass : relation_or_class
        @relation = relation_or_class.all
        @compressed_rules = RulesCompressor.new(@rules.reverse).rules_collapsed.reverse
        StiNormalizer.normalize(@compressed_rules)
        ConditionsNormalizer.normalize(@model_class, @compressed_rules)
      end

      def database_records
        if @model_class.respond_to?(:where) && @model_class.respond_to?(:joins)
          build_relation
        else
          @model_class.all(conditions: conditions, joins: joins)
        end
      end

      def build_relation
        @build_relation ||= begin
          return @model_class.none if @compressed_rules.empty?

          # run the extractor on the reversed set of rules to fill the cache properly
          conditions_extractor = ConditionsExtractor.new(@model_class)
          @compressed_rules.reverse_each { |rule| conditions_extractor.tableize_conditions(rule.conditions) }

          positive_rules, negative_rules = @compressed_rules.partition(&:base_behavior)

          negative_conditions = negative_rules.map { |rule| rule_to_relation(rule, conditions_extractor) }.compact
          positive_conditions = positive_rules.map { |rule| rule_to_relation(rule, conditions_extractor) }.compact

          @relation = @relation.merge(positive_conditions.reduce(&:or)) if positive_conditions.present?
          if negative_conditions.present?
            @relation = @relation.where.not(negative_conditions.reduce(:or).where_clause.ast)
          end

          build_joins_relation(@relation)
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

      def rule_to_relation(rule, conditions_extractor)
        if rule.conditions.is_a? ActiveRecord::Relation
          rule.conditions
        elsif rule.conditions.present?
          @model_class.where(conditions_extractor.tableize_conditions(rule.conditions))
        end
      end

      def build_joins_relation(relation)
        return relation unless joins.present?

        case CanCan.accessible_by_strategy
        when :subquery
          inner = @model_class.unscoped do
            @model_class.left_joins(joins).where(relation.where_clause.ast)
          end
          @model_class.where(@model_class.primary_key => inner)

        when :left_join
          relation.left_joins(joins).distinct
        end
      end

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
    end
  end
end

ActiveSupport.on_load(:active_record) do
  send :include, CanCan::ModelAdditions
end
