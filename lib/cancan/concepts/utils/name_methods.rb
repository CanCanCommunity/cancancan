module CanCan
  module Concepts
    module Utils
      module NameMethods

        def passed_name
          if @name.blank?
            args = @args.dup
            args.extract_options!
            @name = args.first
          end
          @name
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
