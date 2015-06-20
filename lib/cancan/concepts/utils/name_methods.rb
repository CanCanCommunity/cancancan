module CanCan
  module Concepts
    module Utils
      module NameMethods

        def passed_name
          @name ||= @args.first unless @args.first.is_a? Hash
        end

        def name
          passed_name || name_from_controller
        end

        def instance_name
          options[:instance_name] || name
        end

        def name_from_controller
          @controller.params[:controller].split('/').last.singularize
        end

      end
    end
  end
end
