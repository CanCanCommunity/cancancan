module CanCan
  module Concepts
    module Utils
      module Actions

        def collection_actions
          [:index] + Array(options[:collection])
        end

        def new_actions
          [:new, :create] + Array(options[:new])
        end

        def save_actions
          [:create, :update]
        end

        def member_action?
          new_actions.include?(@controller.params[:action].to_sym) || 
          options[:singleton] || 
          ((@controller.params[:id] || @controller.params[options[:id_param]]) && 
            !collection_actions.include?(@controller.params[:action].to_sym))
        end

      end
    end
  end
end
