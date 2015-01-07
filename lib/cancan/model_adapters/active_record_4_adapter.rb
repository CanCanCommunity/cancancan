module CanCan
  module ModelAdapters
    class ActiveRecord4Adapter < AbstractAdapter
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

      # Rails 4.2 deprecates `sanitize_sql_hash_for_conditions`
      def sanitize_sql(conditions)
        if ActiveRecord::VERSION::MINOR >= 2 && Hash === conditions
          relation = @model_class.unscoped.where(conditions)
          predicates = relation.where_values
          bind_values = relation.bind_values
          query = Arel::Nodes::And.new(predicates).to_sql
          conditions = [query, *bind_values.map { |col, val| val }]
        end
        @model_class.send(:sanitize_sql, conditions)
      end
    end
  end
end
