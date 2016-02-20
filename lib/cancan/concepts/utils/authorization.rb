module CanCan
  module Concepts
    module Utils
      module Authorization

        def authorization_action
          parent? ? parent_authorization_action : @controller.params[:action].to_sym
        end

        private

        def parent_authorization_action
          @options[:parent_action] || :show
        end

      end
    end
  end
end
