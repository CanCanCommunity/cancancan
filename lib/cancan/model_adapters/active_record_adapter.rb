require 'cancan/rules_compressor'

module CanCan
  module ModelAdapters
    module ActiveRecordAdapter
      def database_records
        return @model_class.where(nil).merge(override_scope) if override_scope
        rules = RulesCompressor.new(@rules.reverse).rules_collapsed
        return @model_class.where('1 = 0') if rules.none?(&:can_rule?)
        return one_rule_query(rules[0]) if rules.length == 1
        multiple_rules_query(rules)
      end

      private

      def multiple_rules_query(rules)
        relations = build_relations(rules)
        @model_class.select("DISTINCT #{@model_class.table_name}.*")
                    .from("(#{build_sql(relations)}) AS #{@model_class.table_name}")
      end

      def one_rule_query(rule)
        @model_class.where(tableized_conditions(rule.conditions)).joins(joins_for(rule)).distinct
      end

      def build_sql(relations)
        sql = ''
        relations.each_with_index do |relation, index|
          sql << relation[1].to_sql
          if index < relations.length - 1
            sql << (relations[index + 1][0] ? ' UNION ' : ' EXCEPT ')
          end
        end
        sql
      end

      def build_relations(rules)
        rules.map { |rule| [rule.base_behavior, relation_for(rule)] }
      end

      def relation_for(rule)
        @model_class.where(tableized_conditions(rule.conditions)).joins(joins_for(rule))
      end

      def extract_multiple_conditions
        @rules.reverse.inject(false_sql) do |sql, rule|
          merge_conditions(sql, tableized_conditions(rule.conditions).dup, rule.base_behavior)
        end
      end

      def tableized_conditions(conditions, model_class = @model_class)
        return conditions unless conditions.is_a? Hash
        conditions.each_with_object({}) do |(name, value), result_hash|
          calculate_result_hash(model_class, name, result_hash, value)
        end
      end

      def calculate_result_hash(model_class, name, result_hash, value)
        if value.is_a? Hash
          association_class = model_class.reflect_on_association(name).klass.name.constantize
          nested_resulted = calculate_nested(model_class, name, result_hash, value.dup)
          result_hash.merge!(tableized_conditions(nested_resulted, association_class))
        else
          result_hash[name] = value
        end
        result_hash
      end

      def calculate_nested(model_class, name, result_hash, value)
        value.each_with_object({}) do |(k, v), nested|
          if v.is_a? Hash
            value.delete(k)
            nested[k] = v
          else
            result_hash[model_class.reflect_on_association(name).table_name.to_sym] = value
          end
          nested
        end
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

      def joins_for(rule)
        joins_hash = rule.associations_hash
        clean_joins(joins_hash) unless joins_hash.empty?
      end

      # Removes empty hashes and moves everything into arrays.
      def clean_joins(joins_hash)
        joins = []
        joins_hash.each do |name, nested|
          joins << (nested.empty? ? name : { name => clean_joins(nested) })
        end
        joins
      end
    end
  end
end

ActiveSupport.on_load(:active_record) do
  send :include, CanCan::ModelAdditions
end
