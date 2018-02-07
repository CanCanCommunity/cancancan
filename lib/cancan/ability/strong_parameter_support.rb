module CanCan
  module Ability
    module StrongParameterSupport
      # Return an array of attributes suitable for use with strong parameters
      def permitted_attributes(action, subject)
        @permitted_attributes ||= {}
        @permitted_attributes[[action, subject]] ||= allowed_attributes(action, subject)
      end

      private

      def allowed_attributes(action, subject)
        attributes = relevant_rules(action, subject).reduce([]) do |array, rule|
          if rule.attributes.empty? && subject.class == Class # empty attributes is an 'all'
            array + subject.instance_methods.map(&:to_sym)
          else
            array + rule.attributes
          end
        end
        attributes.uniq!
        attributes.select { |attribute| can?(action, subject, attribute) }
      end
    end
  end
end
