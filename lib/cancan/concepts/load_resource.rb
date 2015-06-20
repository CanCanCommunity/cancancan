module CanCan
  module Concepts
    class LoadResource < Base
      extend Forwardable
      include Utils::Parent
      include Utils::IdParam
      include Utils::Actions
      include Utils::ResourceClass
      include Utils::Authorization

      def load
        if load_instance?
          accessor.set(:instance, load_resource_instance) unless accessor.get(:instance)
        elsif load_collection?
          accessor.set(:collection, load_collection) unless accessor.get(:collection)
        end
      end

      protected

      def_delegators :builder, :assign_attributes, :resource_params

      private

      def load_instance?
        parent? || member_action?
      end

      def load_collection?
        resource_class.respond_to?(:accessible_by) &&
        !@controller.current_ability.has_block?(authorization_action, resource_class)
      end

      def load_resource_instance
        (builder.build_resource if builder.can_build?) ||
        (finder.find_resource if finder.can_find?)
      end

      def load_collection
        resource_class.accessible_by(@controller.current_ability, authorization_action)
      end

      def resource_class
        @resource_class ||= ResourceClass.new(@controller, @args).base
      end

      def accessor
        @accessor ||= Accessor.new(@controller, @args)
      end

      def builder
        @builder ||= BuildResource.new(@controller, @args)
      end

      def finder
        @finder ||= FindResource.new(@controller, @args)
      end

    end
  end
end
