module CanCan
  module ModelAdapters
    class ActiveRecord4Adapter < AbstractAdapter
      include ActiveRecordAdapter
      def self.for_class?(model_class)
        model_class <= ActiveRecord::Base
      end

      def self.override_association_matching?(subject, conditions)
        subject.kind_of?(ActiveRecord::Relation) && !subject.loaded?
      end

      def self.matches_association?(subject, conditions)
        where_conditions = association_conditions_for(subject.proxy_association.reflection, conditions)
        subject.where(where_conditions).any?
      end

      def self.association_conditions_for(reflection, conditions)
        {}.tap do |result|
          target = reflection.klass
          conditions.each_pair do |key, value|
            key, value = association_condition_for(target, key, value)
            result[key] = value
          end
        end
      end

      def self.association_condition_for(target, key, value)
        string_key = key.to_s
        if ActiveRecord::VERSION::MINOR >= 1 && target.defined_enums.include?(string_key)
          enum = target.send(string_key.pluralize)
          [key, value.is_a?(Enumerable) ? value.map { |v| enum[v] } : enum[value]]
        elsif value.is_a?(Hash)
          [target.table_name.to_sym, association_conditions_for(target.reflect_on_association(key), value)]
        else
          [key, value]
        end
      end

      private

      # As of rails 4, `includes()` no longer causes active record to
      # look inside the where clause to decide to outer join tables
      # you're using in the where. Instead, `references()` is required
      # in addition to `includes()` to force the outer join.
      def build_relation(*where_conditions)
        relation = @model_class.where(*where_conditions)
        relation = relation.includes(joins).references(joins) if joins.present?
        relation
      end

      def self.override_condition_matching?(subject, name, value)
        # ActiveRecord introduced enums in version 4.1.
        ActiveRecord::VERSION::MINOR >= 1 &&
          subject.class.defined_enums.include?(name.to_s)
      end

      def self.matches_condition?(subject, name, value)
        # Get the mapping from enum strings to values.
        enum = subject.class.send(name.to_s.pluralize)
        # Get the value of the attribute as an integer.
        attribute = enum[subject.send(name)]
        # Check to see if the value matches the condition.
        value.is_a?(Enumerable) ? 
          (value.include? attribute) :
          attribute == value
      end

      # Rails 4.2 deprecates `sanitize_sql_hash_for_conditions`
      def sanitize_sql(conditions)
        if ActiveRecord::VERSION::MINOR >= 2 && Hash === conditions
          table = Arel::Table.new(@model_class.send(:table_name))

          conditions = ActiveRecord::PredicateBuilder.resolve_column_aliases @model_class, conditions
          conditions = @model_class.send(:expand_hash_conditions_for_aggregates, conditions)

          ActiveRecord::PredicateBuilder.build_from_hash(@model_class, conditions, table).map { |b|
            @model_class.send(:connection).visitor.compile b
          }.join(' AND ')
        else
          @model_class.send(:sanitize_sql, conditions)
        end
      end
    end
  end
end
