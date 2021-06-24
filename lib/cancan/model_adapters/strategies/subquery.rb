require_relative 'base_strategy'

module CanCan
  module ModelAdapters
    class Strategies
      class Subquery < BaseStrategy
        def execute!
          build_joins_relation_subquery(where_conditions)
        end

        def build_joins_relation_subquery(where_conditions)
          inner = model_class.unscoped do
            model_class.left_joins(joins).where(*where_conditions)
          end
          model_class.where(model_class.primary_key => inner)
        end
      end
    end
  end
end
