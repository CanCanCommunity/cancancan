module CanCan
  module Ability
    module StrongParameterSupport
      # Return an array of attributes suitable for use with strong parameters
      def permitted_attributes(action, subject)
        @permitted_attributes ||= {}
        @permitted_attributes[[action, subject]] ||= begin
          attributes = relevant_rules(action, subject).reduce([]) { |array, rule| array + rule.attributes }
          attributes += subject.instance_methods.map(&:to_sym) if subject.class == Class
          attributes.uniq!
          attributes.select { |attribute| can?(action, subject, attribute) }
        end
      end
    end
  end
end
