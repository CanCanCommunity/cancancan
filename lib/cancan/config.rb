# frozen_string_literal: true

module CanCan
  def self.valid_accessible_by_strategies
    strategies = [:left_join]
    strategies << :subquery unless does_not_support_subquery_strategy?
    strategies
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
    @accessible_by_strategy || default_accessible_by_strategy
  end

  def self.default_accessible_by_strategy
    if does_not_support_subquery_strategy?
      # see https://github.com/CanCanCommunity/cancancan/pull/655 for where this was added
      # the `subquery` strategy (from https://github.com/CanCanCommunity/cancancan/pull/619
      # only works in Rails 5 and higher
      :left_join
    else
      :subquery
    end
  end

  def self.accessible_by_strategy=(value)
    unless valid_accessible_by_strategies.include?(value)
      raise ArgumentError, "accessible_by_strategy must be one of #{valid_accessible_by_strategies.join(', ')}"
    end

    if value == :subquery && does_not_support_subquery_strategy?
      raise ArgumentError, 'accessible_by_strategy = :subquery requires ActiveRecord 5 or newer'
    end

    @accessible_by_strategy = value
  end

  def self.does_not_support_subquery_strategy?
    !defined?(CanCan::ModelAdapters::ActiveRecordAdapter) ||
      CanCan::ModelAdapters::ActiveRecordAdapter.version_lower?('5.0.0')
  end
end
