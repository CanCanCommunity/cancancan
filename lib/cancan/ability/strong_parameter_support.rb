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
        attributes = relevant_rules(action, subject).flat_map do |rule|
          if rule.attributes.empty? && subject < ActiveRecord::Base # empty attributes is an 'all'
            subject.column_names.map(&:to_sym) - [:id]
          else
            rule.attributes
          end
        end
        attributes.uniq!
        attributes.select { |attribute| can?(action, subject, attribute) }
      end
    end
  end
end
