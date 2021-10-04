# frozen_string_literal: true

module CanCan
  module ModelAdapters
    class ActiveRecord61Adapter < ActiveRecord5Adapter
      AbstractAdapter.inherited(self)

      def self.for_class?(model_class)
        version_greater_or_equal?('6.1.0') && model_class <= ActiveRecord::Base
      end

      # rails 6.1 introduced `relation.and`
      # which is more suitable for intersecting two relations then `relation.merge`
      def database_records
        return super unless override_scope

        if @model_class.all.send(:structurally_incompatible_values_for, override_scope).empty?
          @model_class.and(override_scope)
        else
          # wrap both side in subqeruy to satisfy structural compatibility requirements
          wrap_model_subquery(@model_class.all).and(wrap_model_subquery(override_scope))
        end
      end

      private

      def wrap_model_subquery(scope)
        real_model_class = @model_class.all.klass

        real_model_class.where(real_model_class.primary_key => scope)
      end
    end
  end
end
