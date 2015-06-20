module CanCan
  module Concepts
    module Utils
      module IdParam

        def id_param
          @controller.params[id_param_key].to_s if @controller.params[id_param_key]
        end

        def id_param_key
          if options[:id_param]
            options[:id_param]
          else
            parent? ? :"#{name}_id" : :id
          end
        end

      end
    end
  end
end
