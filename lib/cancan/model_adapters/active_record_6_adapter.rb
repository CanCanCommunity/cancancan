module CanCan
  module ModelAdapters
    class ActiveRecord6Adapter < ActiveRecord5Adapter
      AbstractAdapter.inherited(self)

      def self.for_class?(model_class)
        ActiveRecord::VERSION::MAJOR == 6 && model_class <= ActiveRecord::Base
      end

      def visit_nodes(node)
        connection = @model_class.send(:connection)
        collector = Arel::Collectors::SubstituteBinds.new(connection, Arel::Collectors::SQLString.new)
        connection.visitor.accept(node, collector).value
      end
    end
  end
end
