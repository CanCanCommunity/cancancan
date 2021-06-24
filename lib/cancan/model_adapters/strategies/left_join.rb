require_relative 'base_strategy'

module CanCan
  module ModelAdapters
    class Strategies
      class LeftJoin < BaseStrategy
        def execute!
          relation.left_joins(joins).distinct
        end
      end
    end
  end
end
