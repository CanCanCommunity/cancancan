module CanCan
  module ModelAdapters
    module ActiveRecordAdapter
      module Joins
        # Returns the associations used in conditions for the :joins option of a search.
        # See ModelAdditions#accessible_by
        def joins
          joins_hash = {}
          @rules.reverse.each do |rule|
            merge_joins(joins_hash, rule.associations_hash)
          end
          clean_joins(joins_hash) unless joins_hash.empty?
        end

        private

        # Removes empty hashes and moves everything into arrays.
        def clean_joins(joins_hash)
          joins = []
          joins_hash.each do |name, nested|
            joins << (nested.empty? ? name : { name => clean_joins(nested) })
          end
          joins
        end

        # Takes two hashes and does a deep merge.
        def merge_joins(base, add)
          add.each do |name, nested|
            if base[name].is_a?(Hash)
              merge_joins(base[name], nested) unless nested.empty?
            else
              base[name] = nested
            end
          end
        end
      end
    end
  end
end
