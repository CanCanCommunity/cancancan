# frozen_string_literal: true

module CanCan
  VALID_ACCESSIBLE_BY_STRATEGIES = %i[
    subquery
    left_join
  ].freeze

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
    @accessible_by_strategy || :subquery
  end

  def self.accessible_by_strategy=(value)
    unless VALID_ACCESSIBLE_BY_STRATEGIES.include?(value)
      raise ArgumentError, "accessible_by_strategy must be one of #{VALID_ACCESSIBLE_BY_STRATEGIES.join(', ')}"
    end

    @accessible_by_strategy = value
  end
end
