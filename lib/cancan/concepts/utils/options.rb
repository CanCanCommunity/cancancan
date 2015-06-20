module CanCan
  module Concepts
    module Utils
      module Options

        def options
          @options ||= @args.dup.extract_options!
        end

      end
    end
  end
end
