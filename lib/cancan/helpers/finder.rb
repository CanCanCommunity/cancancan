module CanCan
  module Helpers
    class Finder < Base
      include Utils::Parent
      include Utils::IdParam
      include Utils::ResourceClass

      def can_find?
        id_param || options[:singleton]
      end

      def find_resource
        if options[:singleton] && parent_resource.respond_to?(name)
          parent_resource.send(name)
        else
          if options[:find_by]
            if resource_base.respond_to? find_by_field
              resource_base.send(find_by_field, id_param)
            elsif resource_base.respond_to? :find_by
              resource_base.send(:find_by, { options[:find_by].to_sym => id_param })
            else
              resource_base.send(options[:find_by], id_param)
            end
          else
            adapter.find(resource_base, id_param)
          end
        end
      end

      private

      def adapter
        @adapter ||= ModelAdapters::AbstractAdapter.adapter_class(resource_class)
      end

      def resource_base
        @base ||= ResourceClass.new(@controller, @args).base
      end

      def find_by_field
        :"find_by_#{options[:find_by]}!"
      end

    end
  end
end