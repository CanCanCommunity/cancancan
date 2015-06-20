module CanCan
  module Concepts
    class Base
      attr_reader :controller, :options

      def initialize(controller, name, options = {})
        @controller, @name, @options = controller, name, options
      end

      def resource_name
        @name || name_from_controller
      end

      def instance_name
        options[:instance_name] || resource_name
      end

      def name_from_controller
        @controller.params[:controller].split('/').last.singularize
      end

    end
  end
end
