module CanCan
  module Helpers
    class Skipper < Base

      def skip?(behavior)
        return false unless skip_options = @controller.class.cancan_skipper[behavior][passed_name]

        skip_options == {} ||
        skip_options[:except] && !action_exists_in?(skip_options[:except]) ||
        action_exists_in?(skip_options[:only])
      end

      private

      def action_exists_in?(skip_options)
        Array(skip_options).include?(@controller.params[:action].to_sym)
      end

    end
  end
end
