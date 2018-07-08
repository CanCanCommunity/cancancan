module CanCan
  module ModelAdapters
    class ActiveRecord5Adapter < ActiveRecord4Adapter
      AbstractAdapter.inherited(self)

      def self.for_class?(model_class)
        ActiveRecord::VERSION::MAJOR == 5 && model_class <= ActiveRecord::Base
      end

      # rails 5 is capable of using strings in enum
      # but often people use symbols in rules
      def self.matches_condition?(subject, name, value)
        return super if Array.wrap(value).all? { |x| x.is_a? Integer }

        attribute = subject.send(name)
        if value.is_a?(Enumerable)
          value.map(&:to_s).include? attribute
        else
          attribute == value.to_s
        end
      end

      private

      # As of rails 4, `includes()` no longer causes active record to
      # look inside the where clause to decide to outer join tables
      # you're using in the where. Instead, `references()` is required
      # in addition to `includes()` to force the outer join.
      def build_relation(*where_conditions)
        relation = @model_class.where(*where_conditions)
        relation = relation.includes(joins).references(joins) if joins.present?
        relation
      end

      # Rails 4.2 deprecates `sanitize_sql_hash_for_conditions`
      def sanitize_sql(conditions)
        if conditions.is_a?(Hash)
          sanitize_sql_activerecord5(conditions)
        else
          @model_class.send(:sanitize_sql, conditions)
        end
      end

      def sanitize_sql_activerecord5(conditions)
        table = @model_class.send(:arel_table)
        table_metadata = ActiveRecord::TableMetadata.new(@model_class, table)
        predicate_builder = ActiveRecord::PredicateBuilder.new(table_metadata)

        conditions = predicate_builder.resolve_column_aliases(conditions)

        conditions.stringify_keys!

        predicate_builder.build_from_hash(conditions).map do |b|
          visit_nodes(b)
        end.join(' AND ')
      end

      def visit_nodes(b)
        # Rails 5.2 adds a BindParam node that prevents the visitor method from properly compiling the SQL query
        if ActiveRecord::VERSION::MINOR >= 2
          connection = @model_class.send(:connection)
          collector = Arel::Collectors::SubstituteBinds.new(connection, Arel::Collectors::SQLString.new)
          connection.visitor.accept(b, collector).value
        else
          @model_class.send(:connection).visitor.compile(b)
        end
      end
    end
  end
end
