module CanCan
  module Concepts
    class Authorizer < Base
      include Utils::Parent
      include Utils::ResourceClass
      include Utils::ResourceClassParent
      include Utils::Authorization

      def authorize
        @controller.authorize!(authorization_action, accessor.get(:instance) || resource_class_with_parent)
      end

      private

      def accessor
        @accessor ||= Accessor.new(@controller, @args)
      end

    end
  end
end
