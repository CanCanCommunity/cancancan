module CanCan
  module ModelAdapters
    class ActiveRecord4Adapter < AbstractAdapter
      include ActiveRecordAdapter
      def self.for_class?(model_class)
        ActiveRecord::VERSION::MAJOR == 4 && model_class <= ActiveRecord::Base
      end

      # TODO: this should be private
      def self.override_condition_matching?(subject, name, _value)
        subject.class.defined_enums.include?(name.to_s)
      end

      # TODO: this should be private
      def self.matches_condition?(subject, name, value)
        # Get the mapping from enum strings to values.
        enum = subject.class.send(name.to_s.pluralize)
        # Get the value of the attribute as an integer.
        attribute = enum[subject.send(name)]
        # Check to see if the value matches the condition.
        if value.is_a?(Enumerable)
          value.include? attribute
        else
          attribute == value
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

      # Rails 4.2 deprecates `sanitize_sql_hash_for_conditions`
      def sanitize_sql(conditions)
        if ActiveRecord::VERSION::MINOR >= 2 && conditions.is_a?(Hash)
          sanitize_sql_activerecord4(conditions)
        else
          @model_class.send(:sanitize_sql, conditions)
        end
      end

      def sanitize_sql_activerecord4(conditions)
        table = Arel::Table.new(@model_class.send(:table_name))

        conditions = ActiveRecord::PredicateBuilder.resolve_column_aliases @model_class, conditions
        conditions = @model_class.send(:expand_hash_conditions_for_aggregates, conditions)

        ActiveRecord::PredicateBuilder.build_from_hash(@model_class, conditions, table).map do |b|
          @model_class.send(:connection).visitor.compile b
        end.join(' AND ')
      end
    end
  end
end
