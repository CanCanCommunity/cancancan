module CanCan
  module Helpers
    class Base
      include Utils::NameMethods
      include Utils::Options

      def initialize(controller, args)
        @controller, @args = controller, args
      end

    end
  end
end
