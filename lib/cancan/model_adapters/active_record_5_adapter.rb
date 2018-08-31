module CanCan
  module ModelAdapters
    class ActiveRecord5Adapter < ActiveRecord4Adapter
      AbstractAdapter.inherited(self)

      def self.for_class?(model_class)
        ActiveRecord::VERSION::MAJOR == 5 && model_class <= ActiveRecord::Base
      end

      # rails 5 is capable of using strings in enum
      # but often people use symbols in rules
      def self.matches_condition?(subject, name, value)
        return super if Array.wrap(value).all? { |x| x.is_a? Integer }

        attribute = subject.send(name)
        if value.is_a?(Enumerable)
          value.map(&:to_s).include? attribute
        else
          attribute == value.to_s
        end
      end
    end
  end
end
