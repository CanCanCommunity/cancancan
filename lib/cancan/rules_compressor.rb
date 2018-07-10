require_relative 'conditions_matcher.rb'
module CanCan
  class RulesCompressor
    attr_reader :initial_rules, :rules_collapsed

    def initialize(rules)
      @initial_rules = rules
      @rules_collapsed = @initial_rules.clone
      compress
    end

    def compress
      compress_rules_before_catch_all
      compress_adjacent_rules
      @rules_collapsed = [] if @rules_collapsed.all?(&:cannot_rule?)
      @rules_collapsed.shift if @rules_collapsed.any? && @rules_collapsed.first.cannot_catch_all?
      @rules_collapsed
    end

    # rubocop:disable Metrics/MethodLength
    def compress_adjacent_rules
      deleting = true
      while deleting
        deleting = false
        @rules_collapsed.each_with_index do |rule, index|
          next if index.zero?
          previous_rule = @rules_collapsed[index - 1]
          next unless covers?(previous_rule, rule)
          @rules_collapsed.delete_at(index)
          deleting = true
          break
        end
      end
    end

    private

    def covers?(previous_rule, rule)
      (previous_rule.catch_all? && previous_rule.base_behavior == rule.base_behavior) || (previous_rule == rule)
    end

    def compress_rules_before_catch_all
      catch_all_index = @rules_collapsed.rindex(&:catch_all?)
      @rules_collapsed.slice!(0, catch_all_index) if catch_all_index
    end
  end
end
