module CanCan
  module ModelAdapters
    class ActiveRecord4Adapter < AbstractAdapter
      include ActiveRecordAdapter
      def self.for_class?(model_class)
        model_class <= ActiveRecord::Base
      end

      def tableized_conditions(conditions, model_class = @model_class,
                               current_nesting = [], current_scope = model_class.all)
        return conditions unless conditions.kind_of? Hash
        conditions.inject({}) do |result_hash, (name, value)|
          if value.kind_of? Hash
            value = value.dup
            new_nesting = current_nesting + [name]
            joins_hash = nesting_to_joins_hash(new_nesting)
            current_scope = current_scope.joins(joins_hash)
            association_class = model_class.reflect_on_association(name).klass.name.constantize
            table_name = table_name_for_scope(current_scope).to_sym
            nested = value.inject({}) do |nested,(k,v)|
              if v.kind_of? Hash
                value.delete(k)
                nested[k] = v
              else
                result_hash[table_name] = value
              end
              nested
            end
            result_hash.merge!(tableized_conditions(nested, association_class,
                                                    new_nesting, current_scope))
          else
            result_hash[name] = value
          end
          result_hash
        end
      end

      private

      def table_name_for_scope(current_scope)
        current_table = current_scope.arel.source.right.last.left

        case current_table
        when Arel::Table
          current_table.name
        when Arel::Nodes::TableAlias
          current_table.right
        else
          fail
        end
      end

      def nesting_to_joins_hash(nesting)
        nesting.reverse.reduce(nil) do |a, e|
          if a.nil?
            e
          else
            { e => a }
          end
        end
      end

      # As of rails 4, `includes()` no longer causes active record to
      # look inside the where clause to decide to outer join tables
      # you're using in the where. Instead, `references()` is required
      # in addition to `includes()` to force the outer join.
      def build_relation(*where_conditions)
        relation = @model_class.where(*where_conditions)
        relation = relation.includes(joins).references(joins) if joins.present?
        relation
      end

      def self.override_condition_matching?(subject, name, value)
        # ActiveRecord introduced enums in version 4.1.
        ActiveRecord::VERSION::MINOR >= 1 &&
          subject.class.defined_enums.include?(name.to_s)
      end

      def self.matches_condition?(subject, name, value)
        # Get the mapping from enum strings to values.
        enum = subject.class.send(name.to_s.pluralize)
        # Get the value of the attribute as an integer.
        attribute = enum[subject.send(name)]
        # Check to see if the value matches the condition.
        value.is_a?(Enumerable) ? 
          (value.include? attribute) :
          attribute == value
      end

      # Rails 4.2 deprecates `sanitize_sql_hash_for_conditions`
      def sanitize_sql(conditions)
        if ActiveRecord::VERSION::MINOR >= 2 && Hash === conditions
          table = Arel::Table.new(@model_class.send(:table_name))

          conditions = ActiveRecord::PredicateBuilder.resolve_column_aliases @model_class, conditions
          conditions = @model_class.send(:expand_hash_conditions_for_aggregates, conditions)

          ActiveRecord::PredicateBuilder.build_from_hash(@model_class, conditions, table).map { |b|
            @model_class.send(:connection).visitor.compile b
          }.join(' AND ')
        else
          @model_class.send(:sanitize_sql, conditions)
        end
      end
    end
  end
end
