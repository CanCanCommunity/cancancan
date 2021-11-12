module CanCan
  module ModelAdapters
    class Strategies
      class ExistsSubquery < Base
        def execute!
          model_class.where(joined_alias_exists_subquery_inner_query.arel.exists)
        end

        def joined_alias_exists_subquery_inner_query
          model_class
            .select('1')
            .left_joins(joins)
            .where(*where_conditions)
            .where(
              "#{quoted_table_name}.#{quoted_primary_key} = " \
              "#{quoted_aliased_table_name}.#{quoted_primary_key}"
            )
        end
      end
    end
  end
end
