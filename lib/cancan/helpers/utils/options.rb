module CanCan
  module Helpers
    module Utils
      module Options

        def options
          @options ||= @args.dup.extract_options!
        end

      end
    end
  end
end
