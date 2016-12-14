module CanCan
  module ModelAdapters
    class ActiveRecord4Adapter < AbstractAdapter
      include ActiveRecordAdapter
      def self.for_class?(model_class)
        model_class <= ActiveRecord::Base
      end

      def tableized_conditions(conditions)
        scope = joined_scope
        table_aliases = build_table_aliases(scope)
        tableize_conditions(conditions, table_aliases, [])
      end

      private

      def tableize_conditions(conditions, table_aliases, current_nesting)
        return conditions unless conditions.kind_of? Hash
        conditions.inject({}) do |result_hash, (name, value)|
          if value.kind_of? Hash
            new_nesting = current_nesting + [name]
            table_name = table_name_for_nesting(new_nesting, table_aliases)

            nested_conditions = {}
            current_conditions = {}
            value.each do |(k,v)|
              if v.kind_of? Hash
                nested_conditions[k] = v
              else
                current_conditions[k] = v
              end
            end
            result_hash[table_name] = current_conditions unless current_conditions.empty?
            result_hash.merge!(tableize_conditions(nested_conditions, table_aliases, new_nesting))
          else
            result_hash[name] = value
          end
          result_hash
        end
      end

      def table_name_for_nesting(nesting, table_aliases)
        keypath = nesting.join('.')
        table_aliases.fetch(keypath) { fail ArgumentError }
      end

      # As of rails 4, `includes()` no longer causes active record to
      # look inside the where clause to decide to outer join tables
      # you're using in the where. Instead, `references()` is required
      # in addition to `includes()` to force the outer join.
      def build_relation(*where_conditions)
        joined_scope.where(*where_conditions)
      end

      def joined_scope
        relation = @model_class.all
        relation = relation.includes(joins).references(joins) if joins.present?
        relation
      end

      def build_table_aliases(scope)
        aliases = {}
        build_table_alias(build_join_dependency_root(scope), aliases, [])
        aliases
      end

      def build_table_alias(join_part, aliases, nesting)
        join_part.children.each do |join_child|
          new_nesting = nesting + [join_child.name]
          aliases[new_nesting.join('.')] = join_child.aliased_table_name.to_sym
          build_table_alias(join_child, aliases, new_nesting)
        end
      end

      if ActiveRecord::VERSION::MINOR >= 1
        def build_join_dependency_root(scope)
          scope.send(:construct_join_dependency, scope.joins_values).join_root
        end
      else
        def build_join_dependency_root(scope)
          build_join_dependency(scope).join_base
        end

        def build_join_dependency(scope)
          ActiveRecord::Associations::JoinDependency.new(scope.klass, scope.eager_load_values +
                                                         scope.includes_values, scope.joins_values)
        end
      end

      def self.override_condition_matching?(subject, name, value)
        # ActiveRecord introduced enums in version 4.1.
        (ActiveRecord::VERSION::MAJOR > 4 || ActiveRecord::VERSION::MINOR >= 1) &&
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
        if ActiveRecord::VERSION::MAJOR > 4 && Hash === conditions
          table = @model_class.send(:arel_table)
          table_metadata = ActiveRecord::TableMetadata.new(@model_class, table)
          predicate_builder = ActiveRecord::PredicateBuilder.new(table_metadata)

          conditions = predicate_builder.resolve_column_aliases(conditions)
          conditions = @model_class.send(:expand_hash_conditions_for_aggregates, conditions)

          conditions.stringify_keys!

          predicate_builder.build_from_hash(conditions).map { |b|
            @model_class.send(:connection).visitor.compile b
          }.join(' AND ')
        elsif ActiveRecord::VERSION::MINOR >= 2 && Hash === conditions
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
