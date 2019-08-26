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
        relation = @model_class.all
        return relation unless where_conditions.any?(&:present?) || joins.present?

        relation = relation.where(*where_conditions)
        relation = add_joins_to_relation(relation)
        extract_ids_and_requery(relation)
      end

      def extract_ids_and_requery(relation)
        need_to_extract_ids = relation.values[:distinct].present? || relation.values[:order].present?

        # we need to extract IDs if the query has a builtin `distinct` or `order`. an example of when
        # would be a `default_scope` that adds either. this is because otherwise you'll call
        # SELECT DISTINCT @model_class.* ORDER BY ___, but there's no guarantee that the columns you
        # order by will be included in the SELECT. a previously attempted solution was to add
        # SELECTs for all the ORDER depends on (see https://github.com/CanCanCommunity/cancancan/pull/600)
        # but this breaks COUNT queries. the simplest general purpose solution is to get IDs for all
        # records that match the cancan criteria, then do *another* query that re-adds the default scope.
        # this is what we do here.
        # the main downside is some queries cancan generates will now look a bit uglier.
        if need_to_extract_ids
          @model_class.where(id: relation.reorder(nil).select("id").distinct)
        else
          # if we don't already have a `distinct` (relation.values[:distinct].blank?)
          # but we have added a join, we need to add our own `distinct`.
          relation = relation.distinct if joins.present?
          relation
        end
      end

      def add_joins_to_relation(relation)
        return relation unless joins.present?

        # AR#left_joins doesn't play nicely in AR 5.0 and 5.1
        # see https://github.com/CanCanCommunity/cancancan/pull/600#issuecomment-524672268
        if self.class.version_greater_or_equal?('5.2')
          relation.left_joins(joins)
        else
          relation.includes(joins).references(joins)
        end
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
    end
  end
end
