require_relative 'conditions_matcher.rb'
module CanCan
  class RulesCompressor
    attr_reader :initial_rules, :rules_collapsed

    def initialize(rules)
      @initial_rules = rules
      @rules_collapsed = @initial_rules.reverse
      compress
    end

    def compress
      compress_cannot_rules
      compress_can_rules

      while !@rules_collapsed.empty? && @rules_collapsed.first.cannot_rule?
        if @rules_collapsed.all?(&:cannot_rule?)
          @rules_collapsed = []
        elsif !@rules_collapsed.first.with_conditions?
          @rules_collapsed.shift
        end
      end

      @rules_collapsed
    end

    private

    def compress_can_rules
      return unless @rules_collapsed.length > 1
      @rules_collapsed.each_with_index do |rule, index|
        next if index >= @rules_collapsed.length - 1
        next unless rule.can_rule?
        next if rule.with_conditions?
        next unless @rules_collapsed[index + 1].can_rule?
        @rules_collapsed.delete_at(index + 1)
      end
    end

    def compress_cannot_rules
      return unless @rules_collapsed.length > 1
      @rules_collapsed.each_with_index do |rule, index|
        next if index >= @rules_collapsed.length - 1
        next unless rule.cannot_rule?
        next if rule.with_conditions?
        next unless @rules_collapsed[index + 1].cannot_rule?
        @rules_collapsed.delete_at(index)
      end
    end
  end
end
