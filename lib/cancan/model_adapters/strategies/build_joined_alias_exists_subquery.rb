require_relative 'base_strategy'

module CanCan
  module ModelAdapters
    class ActiveRecordAdapter
      class BuildJoinedAliasExistsSubquery < BaseStrategy
        attr_reader :adapter, :where_conditions

        delegate :model_class, to: :adapter

        def initialize(adapter:, where_conditions:)
          @adapter = adapter
          @where_conditions = where_conditions
        end

        def execute!
          build_joined_alias_exists_subquery
        end

        def build_joined_alias_exists_subquery
          model_class
            .joins(
              "JOIN #{quoted_table_name} AS #{quoted_aliased_table_name} ON " \
              "#{quoted_aliased_table_name}.#{quoted_primary_key} = #{quoted_table_name}.#{quoted_primary_key}"
            )
            .where("EXISTS (#{joined_alias_exists_subquery_inner_query.to_sql})")
        end

        def joined_alias_exists_subquery_inner_query
          model_class
            .unscoped
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
