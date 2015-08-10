module ArOuterJoins
  class Join
    attr_reader :klass

    def initialize(klass)
      @klass = klass
    end

    def generate(*args)
      args.flatten.compact.map do |arg|
        if arg.is_a?(Hash)
          arg.map do |key, value|
            association = klass.reflect_on_association(key)
            generate(key) + Join.new(association.klass).generate(value)
          end
        else
          JoinBuilder.new(klass.reflect_on_association(arg)).build
        end
      end
    end

    def apply(*args)
      scope = if klass.all.is_a?(ActiveRecord::Relation) then klass.all else klass.scoped end
      joins = scope.joins_values.select.map { |j| j.to_sql if j.respond_to?(:to_sql) }
      generate(*args).flatten.inject(scope) do |scope, join|
        if joins.include?(join.to_sql)
          scope
        else
          scope.joins(join)
        end
      end
    end
  end
end
