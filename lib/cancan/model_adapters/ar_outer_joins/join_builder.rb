module ArOuterJoins
  class JoinBuilder
    class OuterJoinError < StandardError; end

    attr_reader :association

    def initialize(association)
      @association = association
    end

    def build
      if association.is_a? ActiveRecord::Reflection::ThroughReflection
        [
          JoinBuilder.new(association.through_reflection).build,
          JoinBuilder.new(association.source_reflection).build
        ].flatten
      else
        table = association.active_record.arel_table
        primary_key = association.active_record.primary_key
        joined_table = association.klass.arel_table

        case association.macro
          when :belongs_to
            on = Arel::Nodes::On.new(table[association.foreign_key].eq(joined_table[primary_key]))
            [Arel::Nodes::OuterJoin.new(joined_table, on)]
          when :has_and_belongs_to_many
            join_model_table = if association.respond_to?(:join_table)
                                 Arel::Table.new(association.join_table)
                               else
                                 Arel::Table.new(association.options[:join_table])
                               end
            joined_primary_key = association.klass.primary_key

            on1 = Arel::Nodes::On.new(join_model_table[association.foreign_key].eq(table[primary_key]))
            on2 = Arel::Nodes::On.new(join_model_table[association.association_foreign_key].eq(joined_table[joined_primary_key]))

            [Arel::Nodes::OuterJoin.new(join_model_table, on1), Arel::Nodes::OuterJoin.new(joined_table, on2)]
          when :has_many, :has_one
            on = Arel::Nodes::On.new(joined_table[association.foreign_key].eq(table[primary_key]))
            [Arel::Nodes::OuterJoin.new(joined_table, on)]
          else
            raise OuterJoinError, "don't know what to do with #{association.macro} association"
        end
      end
    end
  end
end
