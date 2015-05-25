module CanCan
  module Helpers
    module Utils
      module ResourceClassParent

        def resource_class_with_parent
          parent_resource ? {parent_resource => resource_class} : resource_class
        end

      end
    end
  end
end