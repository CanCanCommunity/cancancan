module CanCan
  module Helpers
    class Accessor < Base

      def get(instance_or_collection)
        @controller.instance_variable_get ivar_name(instance_or_collection)
      end

      def set(instance_or_collection, instance)
        @controller.instance_variable_set ivar_name(instance_or_collection), instance
      end

      private

      def ivar_name(instance_or_collection)
        case instance_or_collection
        when :instance   then :"@#{instance_name}"
        when :collection then :"@#{instance_name.to_s.pluralize}"
        end
      end

    end
  end
end
