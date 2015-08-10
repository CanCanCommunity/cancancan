require "cancan/model_adapters/ar_outer_joins/join_builder"
require "cancan/model_adapters/ar_outer_joins/join"

module ArOuterJoins
  def outer_joins(*joins)
    association_joins, regular_joins = joins.partition do |join|
      join.is_a?(Hash) or join.is_a?(Array) or join.is_a?(Symbol)
    end
    join_set = Join.new(self).apply(*association_joins)
    join_set = join_set.joins(*regular_joins) unless regular_joins.empty?
    join_set
  end
end

ActiveRecord::Base.extend ArOuterJoins
