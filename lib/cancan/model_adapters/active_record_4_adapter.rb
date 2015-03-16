module CanCan
  module ModelAdapters
    class ActiveRecord4Adapter < AbstractAdapter
      include ActiveRecordAdapter

      class << self
        def for_class?(model_class)
          model_class <= ActiveRecord::Base
        end

        def override_condition_matching?(subject, name, value)
          name == :not || super
        end

        def matches_condition?(subject, name, value)
          if name == :not && value.kind_of?(Hash)
            value.none? {|attribute, test| subject.send(attribute) == test }
          else
            super
          end
        end
      end

      private

      def association_condition?(name, value)
        name != :not && super
      end

      # As of rails 4, `includes()` no longer causes active record to
      # look inside the where clause to decide to outer join tables
      # you're using in the where. Instead, `references()` is required
      # in addition to `includes()` to force the outer join.
      def build_relation(*where_conditions)
        if where_conditions.kind_of?(Array) && where_conditions.size == 1
          condition = where_conditions.first
          if condition.kind_of? Hash
            not_conditions = condition.delete(:not)
            where_conditions = [condition]
          end
        end

        relation = @model_class.where(*where_conditions)
        relation = relation.where.not(not_conditions) if not_conditions
        relation = relation.includes(joins).references(joins) if joins.present?
        relation
      end

      def merge_joins(base, add)
        add.delete :not
        super base, add
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
