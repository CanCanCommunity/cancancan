# frozen_string_literal: true

require_relative 'conditions_matcher.rb'
module CanCan
  class RulesCompressor
    attr_reader :initial_rules, :rules_collapsed

    def initialize(rules)
      @initial_rules = rules
      @rules_collapsed = compress(@initial_rules)
    end

    def compress(array)
      idx = array.rindex(&:catch_all?)
      return array unless idx

      value = array[idx]
      array[idx..-1]
        .drop_while { |n| n.base_behavior == value.base_behavior }
        .tap { |a| a.unshift(value) unless value.cannot_catch_all? }
    end
  end
end
