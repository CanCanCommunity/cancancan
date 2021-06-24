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
        when :joined_alias_each_rule_as_exists_subquery
          build_joined_alias_each_rule_as_exists_subquery(where_conditions)
        when :joined_alias_exists_subquery
          build_joined_alias_exists_subquery(where_conditions)
        when :subquery
          build_joins_relation_subquery(where_conditions)
        when :left_join
          relation.left_joins(joins).distinct
        end
      end

      def build_joined_alias_each_rule_as_exists_subquery(where_conditions)
        double_exists_sql = '' + ''

        @compressed_rules.each_with_index do |rule, index|
          conditions_extractor = ConditionsExtractor.new(@model_class)
          rule_where_conditions = extract_multiple_conditions(conditions_extractor, [rule])
          joins_hash, left_joins_hash = extract_joins_from_rule(rule)

          sub_query = @model_class
            .select("1")
            .joins(joins_hash)
            .left_joins(left_joins_hash)
            .where(
              "#{quoted_table_name}.#{quoted_primary_key} = " \
              "#{quoted_aliased_table_name}.#{quoted_primary_key}"
            )
            .where(rule_where_conditions)
            .limit(1)

          double_exists_sql << " OR " if index > 0
          double_exists_sql << "EXISTS (#{sub_query.to_sql})"
        end

        @model_class
          .unscoped
          .joins(
            "INNER JOIN #{quoted_table_name} AS #{quoted_aliased_table_name} ON " \
            "#{quoted_aliased_table_name}.#{quoted_primary_key} = #{quoted_table_name}.#{quoted_primary_key}"
          )
          .where(double_exists_sql)
      end

      def extract_joins_from_rule(rule)
        joins = {}
        left_joins = {}

        extra_joins_recursive([], rule.conditions, joins, left_joins)
        [joins, left_joins]
      end

      def extra_joins_recursive(current_path, conditions, joins, left_joins)
        conditions.each do |key, value|
          if value.is_a?(Hash)
            current_path << key
            extra_joins_recursive(current_path, value, joins, left_joins)
            current_path.pop
          else
            hash_joins = {}
            current_hash_joins = hash_joins

            current_path.each do |path_part|
              new_hash = {}
              current_hash_joins[path_part] = new_hash
              current_hash_joins = new_hash
            end

            if value.nil?
              left_joins.deep_merge!(hash_joins)
            else
              joins.deep_merge!(hash_joins)
            end
          end
        end
      end

      def build_joins_relation_subquery(where_conditions)
        inner = @model_class.unscoped do
          @model_class.left_joins(joins).where(*where_conditions)
        end
        @model_class.where(@model_class.primary_key => inner)
      end

      def build_joined_alias_exists_subquery(where_conditions)
        @model_class
          .unscoped
          .joins(
            "INNER JOIN #{quoted_table_name} AS #{quoted_aliased_table_name} ON " \
            "#{quoted_aliased_table_name}.#{quoted_primary_key} = #{quoted_table_name}.#{quoted_primary_key}"
          )
          .where("EXISTS (#{joined_alias_exists_subquery_inner_query(where_conditions).to_sql})")
      end

      def joined_alias_exists_subquery_inner_query(where_conditions)
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
