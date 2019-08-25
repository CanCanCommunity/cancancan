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

      def build_relation(*where_conditions)
        relation = @model_class.where(*where_conditions)
        relation = relation.left_joins(joins).distinct if joins.present?
        fix_order_select_distinct(relation)
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

        predicate_builder.build_from_hash(conditions).map { |b| visit_nodes(b) }.join(' AND ')
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

      #### METHODS BELOW FROM kaspernj/active_record_query_fixer ####
      # I don't expect this to get merged without more tidying up.

      # rubocop:disable Metrics/MethodLength,Metrics/AbcSize

      # from https://github.com/kaspernj/active_record_query_fixer/blob/master/lib/active_record_query_fixer.rb#L32
      def fix_order_select_distinct(query)
        return query unless query.values[:distinct].present? && query.values[:order].present?

        @count_select ||= 0
        changed = false
        query.values[:order].each do |order|
          select = "#{extract_table_and_column_from_expression(order)} AS active_record_query_fixer_#{@count_select}"
          query = query.select(select)
          changed = true
          @count_select += 1
        end

        query = query.select("#{query.table_name}.*") if changed
        query
      end

      # https://github.com/kaspernj/active_record_query_fixer/blob/master/lib/active_record_query_fixer.rb#L54
      def extract_table_and_column_from_expression(order)
        if order.is_a?(Arel::Nodes::Ascending) || order.is_a?(Arel::Nodes::Descending)
          if order.expr.relation.respond_to?(:right)
            "#{order.expr.relation.right}.#{order.expr.name}"
          else
            "#{order.expr.relation.table_name}.#{order.expr.name}"
          end
        elsif order.is_a?(String)
          order
        else
          raise "Couldn't extract table and column from: #{order}"
        end
      end

      # rubocop:enable Metrics/MethodLength,Metrics/AbcSize

      #### METHODS ABOVE FROM kaspernj/active_record_query_fixer ####
    end
  end
end
