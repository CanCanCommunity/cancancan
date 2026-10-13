# frozen_string_literal: true

module CanCan
  # Decides whether the loading or the authorization of a resource is skipped through
  # skip_load_resource, skip_authorize_resource or skip_load_and_authorize_resource.
  # The options are combined like in a before_action: every given option must match.
  module ControllerResourceSkipper
    def skip?(behavior)
      options = @controller.class.cancan_skipper[behavior][@name]
      return false unless options

      action_matches?(options) && conditions_met?(options)
    end

    private

    def action_matches?(options)
      (options[:only].nil? || action_exists_in?(options[:only])) &&
        (options[:except].nil? || !action_exists_in?(options[:except]))
    end

    def conditions_met?(options)
      (options[:if].nil? || condition_met?(options[:if])) &&
        (options[:unless].nil? || !condition_met?(options[:unless]))
    end

    def action_exists_in?(actions)
      Array(actions).include?(@params[:action].to_sym)
    end

    def condition_met?(condition)
      result = condition.respond_to?(:call) ? call_condition(condition) : @controller.send(condition)
      !!result
    end

    def call_condition(condition)
      condition.arity.zero? ? @controller.instance_exec(&condition) : condition.call(@controller)
    end
  end
end
