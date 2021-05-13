# frozen_string_literal: true

module CanCan
  module ModelAdapters
    class ActiveRecord5Adapter < ActiveRecord4Adapter
      AbstractAdapter.inherited(self)

      def self.for_class?(model_class)
        version_greater_or_equal?('5.0.0') && model_class <= ActiveRecord::Base
      end

      # rails 5 is capable of using strings in enum
      # but often people use symbols in rules
      def self.matches_condition?(subject, name, value)
        return super if Array.wrap(value).all? { |x| x.is_a? Integer }

        attribute = subject.send(name)
        raw_attribute = subject.class.send(name.to_s.pluralize)[attribute]
        !(Array(value).map(&:to_s) & [attribute, raw_attribute]).empty?
      end

      private

      delegate :connection, :quoted_primary_key, to: :@model_class
      delegate :quote_table_name, to: :connection

      def build_joins_relation(relation, *where_conditions)
        case CanCan.accessible_by_strategy
        when :subquery
          build_joins_relation_subquery(where_conditions)
        when :left_join
          relation.left_joins(joins).distinct
        when :double_exist_subquery
          build_joins_relation_double_exist_subquery(where_conditions)
        end
      end

      def build_joins_relation_subquery(where_conditions)
        inner = @model_class.unscoped do
          @model_class.left_joins(joins).where(*where_conditions)
        end
        @model_class.where(@model_class.primary_key => inner)
      end

      def build_joins_relation_double_exist_subquery(where_conditions)
        @model_class.where("EXISTS (#{double_exists_query_sql(where_conditions)})")
      end

      def double_exists_inner_query(where_conditions)
        @model_class
          .unscoped
          .select('1')
          .left_joins(joins)
          .where(*where_conditions)
          .where(
            "#{quoted_table_name}.#{quoted_primary_key} = " \
            "#{quoted_aliased_table_name}.#{quoted_primary_key}"
          )
      end

      def double_exists_query_sql(where_conditions)
        'SELECT 1 ' \
        "FROM #{quoted_table_name} AS #{quoted_aliased_table_name} " \
        'WHERE ' \
        "#{quoted_aliased_table_name}.#{quoted_primary_key} = #{quoted_table_name}.#{quoted_primary_key} AND " \
        "EXISTS (#{double_exists_inner_query(where_conditions).to_sql})"
      end

      def quoted_aliased_table_name
        @quoted_aliased_table_name ||= quote_table_name('aliased_table')
      end

      def quoted_table_name
        @quoted_table_name ||= quote_table_name(@model_class.table_name)
      end

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

        predicate_builder.build_from_hash(conditions.stringify_keys).map { |b| visit_nodes(b) }.join(' AND ')
      end

      def visit_nodes(node)
        # Rails 5.2 adds a BindParam node that prevents the visitor method from properly compiling the SQL query
        if self.class.version_greater_or_equal?('5.2.0')
          connection = @model_class.send(:connection)
          collector = Arel::Collectors::SubstituteBinds.new(connection, Arel::Collectors::SQLString.new)
          connection.visitor.accept(node, collector).value
        else
          @model_class.send(:connection).visitor.compile(node)
        end
      end
    end
  end
end
