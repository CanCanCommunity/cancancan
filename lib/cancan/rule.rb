require_relative 'conditions_matcher.rb'
module CanCan
  # This class is used internally and should only be called through Ability.
  # it holds the information about a "can" call made on Ability and provides
  # helpful methods to determine permission checking and conditions hash generation.
  class Rule # :nodoc:
    include ConditionsMatcher
    attr_reader :base_behavior, :subjects, :actions, :conditions, :attributes, :block
    attr_writer :expanded_actions

    def initialize(base_behavior, action, subject, conditions, block)
      both_block_and_hash_error = 'You are not able to supply a block with a hash of conditions in '\
                                  "#{action} #{subject} ability. Use either one."
      raise Error, both_block_and_hash_error if conditions.is_a?(Hash) && block
      @conditions = conditions || {}
    end

    def can_rule?
      base_behavior
    end

    def cannot_rule?
      !base_behavior
    end

    def can_catch_all?
      can_rule? && catch_all?
    end

    def cannot_catch_all?
      cannot_rule? && catch_all?
    end

    def catch_all?
      [nil, false, [], {}, '', ' '].include? @conditions
    end

    # rubocop:disable Metrics/AbcSize
    def ==(other)
      base_behavior == other.base_behavior &&
        actions == other.actions &&
        subjects == other.subjects &&
        attributes == other.attributes &&
        conditions == other.conditions &&
        block == other.block
    end

    def to_s
      "#{base_behavior ? 'can' : 'cannot'} [#{actions.map { |a| ":#{a}" }.join(', ')}],"\
"#{subjects.inspect}, #{conditions.inspect}"
    end

    # Matches the action, subject, and attribute; not necessarily the conditions
    def relevant?(action, subject)
      subject = subject.values.first if subject.class == Hash
      @match_all || (matches_action?(action) && matches_subject?(subject))
    end

    def only_block?
      conditions_empty? && @block
    end

    def only_raw_sql?
      @block.nil? && !conditions_empty? && !@conditions.is_a?(Hash)
    end

    def associations_hash(conditions = @conditions)
      hash = {}
      if conditions.is_a? Hash
        conditions.map do |name, value|
          hash[name] = associations_hash(value) if value.is_a? Hash
        end
      end
      hash
    end

    def attributes_from_conditions
      attributes = {}
      if @conditions.is_a? Hash
        @conditions.each do |key, value|
          attributes[key] = value unless [Array, Range, Hash].include? value.class
        end
      end
      attributes
    end

    def matches_attributes?(attribute)
      return true if @attributes.empty?
      return @base_behavior if attribute.nil?
      @attributes.include?(attribute.to_sym)
    end

    private

    def matches_action?(action)
      @expanded_actions.include?(:manage) || @expanded_actions.include?(action)
    end

    def matches_subject?(subject)
      @subjects.include?(:all) || @subjects.include?(subject) || matches_subject_class?(subject)
    end

    def matches_subject_class?(subject)
      @subjects.any? do |sub|
        sub.is_a?(Module) && (subject.is_a?(sub) ||
          subject.class.to_s == sub.to_s ||
          (subject.is_a?(Module) && subject.ancestors.include?(sub)))
      end
    end

    def parse_attributes_from_extra_args(args)
      attributes = args.shift if valid_attribute_param?(args.first)
      extra_args = args.shift

      [attributes, extra_args]
    end

    def condition_and_block_check(conditions, block, action, subject)
      return unless conditions.is_a?(Hash) && block
      raise BlockAndConditionsError, 'A hash of conditions is mutually exclusive with a block.'\
        "Check #{action} #{subject} ability."
    end
  end
end
