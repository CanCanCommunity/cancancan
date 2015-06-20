module CanCan
  module Concepts
    class ResourceClass < Base
      include Utils::Parent
      include Utils::ResourceClass
      include Utils::Authorization

      def base
        if options[:through]
          if parent_resource
            base = options[:singleton] ? resource_class : parent_through_class
            base = base.scoped if base.respond_to?(:scoped) && defined?(ActiveRecord) && ActiveRecord::VERSION::MAJOR == 3
            base
          elsif options[:shallow]
            resource_class
          else
            raise AccessDenied.new(nil, authorization_action, resource_class) # maybe this should be a record not found error instead?
          end
        else
          resource_class
        end
      end

      private

      def active_record_v3?
        defined?(ActiveRecord) && ActiveRecord::VERSION::MAJOR == 3
      end

      def parent_through_class
        parent_resource.send(options[:through_association] || name.to_s.pluralize)
      end

    end
  end
end
