module CanCan
  module ModelAdapters
    class ActiveRecord3Adapter < AbstractAdapter
      include ActiveRecordAdapter
      def self.for_class?(model_class)
        model_class <= ActiveRecord::Base
      end

      private

      def build_relation(*where_conditions)
        @model_class.where(*where_conditions).includes(joins)
      end
    end
  end
end
