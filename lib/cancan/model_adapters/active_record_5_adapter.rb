module CanCan
  module ModelAdapters
    class ActiveRecord5Adapter < AbstractAdapter
      include ActiveRecordAdapter
      def self.for_class?(model_class)
        model_class <= ActiveRecord::Base
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
        if Hash === conditions
          table = @model_class.send(:arel_table)
          table_metadata = ActiveRecord::TableMetadata.new(@model_class, table)
          predicate_builder = ActiveRecord::PredicateBuilder.new(table_metadata)

          conditions = predicate_builder.resolve_column_aliases(conditions)
          conditions = @model_class.send(:expand_hash_conditions_for_aggregates, conditions)

          conditions.stringify_keys!

          conditions, binds = predicate_builder.create_binds(conditions)

          predicate_builder.build_from_hash(conditions).map { |b|
            @model_class.send(:connection).visitor.compile b
          }.join(' AND ')
        else
          @model_class.send(:sanitize_sql, conditions)
        end
      end
    end
  end
end
