module CanCan
  module Concepts
    module Utils
      module Authorization

        def authorization_action
          parent? ? :show : @controller.params[:action].to_sym
        end

      end
    end
  end
end
