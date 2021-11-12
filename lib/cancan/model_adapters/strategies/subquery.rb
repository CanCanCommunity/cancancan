module CanCan
  module ModelAdapters
    class Strategies
      class Subquery < Base
        def execute!
          inner = model_class.unscoped { model_class.left_joins(joins).where(*where_conditions) }
          model_class.where(model_class.primary_key => inner)
        end
      end
    end
  end
end
