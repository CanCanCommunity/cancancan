module CanCan
  module ModelAdapters
    class ActiveRecord3Adapter < AbstractAdapter
      include ActiveRecordAdapter
      def self.for_class?(model_class)
        model_class <= ActiveRecord::Base
      end

      def tableized_conditions(conditions, model_class = @model_class)
        return conditions unless conditions.kind_of? Hash
        conditions.inject({}) do |result_hash, (name, value)|
          if value.kind_of? Hash
            value = value.dup
            association_class = model_class.reflect_on_association(name).klass.name.constantize
            nested = value.inject({}) do |nested,(k,v)|
              if v.kind_of? Hash
                value.delete(k)
                nested[k] = v
              else
                result_hash[model_class.reflect_on_association(name).table_name.to_sym] = value
              end
              nested
            end
            result_hash.merge!(tableized_conditions(nested,association_class))
          else
            result_hash[name] = value
          end
          result_hash
        end
      end

      private

      def build_relation(*where_conditions)
        @model_class.where(*where_conditions).includes(joins)
      end
    end
  end
end
