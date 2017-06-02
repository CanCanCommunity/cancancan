module CanCan
  module ModelAdapters
    class ActiveRecord4Adapter < AbstractAdapter
      include ActiveRecordAdapter
      def self.for_class?(model_class)
        model_class <= ActiveRecord::Base
      end

      # TODO: this should be private
      def self.override_condition_matching?(subject, name, _value)
        subject.class.defined_enums.include?(name.to_s)
      end

      # TODO: this should be private
      def self.matches_condition?(subject, name, value)
        # Get the mapping from enum strings to values.
        enum = subject.class.send(name.to_s.pluralize)
        # Get the value of the attribute as an integer.
        attribute = enum[subject.send(name)]
        # Check to see if the value matches the condition.
        if value.is_a?(Enumerable)
          value.include? attribute
        else
          attribute == value
        end
      end
    end
  end
end
