# frozen_string_literal: true

module CanCan
  def self.valid_accessible_by_strategies
    %i[left_join subquery]
  end

  # Determines how CanCan should build queries when calling accessible_by,
  # if the query will contain a join. The default strategy is `:subquery`.
  #
  #   # config/initializers/cancan.rb
  #   CanCan.accessible_by_strategy = :subquery
  #
  # Valid strategies are:
  # - :subquery - Creates a nested query with all joins, wrapped by a
  #               WHERE IN query.
  # - :left_join - Calls the joins directly using `left_joins`, and
  #                ensures records are unique using `distinct`. Note that
  #                `distinct` is not reliable in some cases. See
  #                https://github.com/CanCanCommunity/cancancan/pull/605
  def self.accessible_by_strategy
    return @accessible_by_strategy if @accessible_by_strategy

    @accessible_by_strategy = default_accessible_by_strategy
  end

  def self.default_accessible_by_strategy
    # see https://github.com/CanCanCommunity/cancancan/pull/655 for where this was added
    # the `subquery` strategy (from https://github.com/CanCanCommunity/cancancan/pull/619
    :left_join
  end

  def self.accessible_by_strategy=(value)
    @accessible_by_strategy = value
  end

  def self.with_accessible_by_strategy(value)
    return yield if value == accessible_by_strategy

    begin
      strategy_was = accessible_by_strategy
      @accessible_by_strategy = value
      yield
    ensure
      @accessible_by_strategy = strategy_was
    end
  end
end
