module CanCan
  module ConditionsMatcher
    # Matches the block or conditions hash
    def matches_conditions?(action, subject, extra_args)
      return call_block_with_all(action, subject, extra_args) if @match_all
      return @block.call(subject, *extra_args) if @block && !subject_class?(subject)
      matches_non_block_conditions(subject)
    end

    private

    def subject_class?(subject)
      klass = (subject.is_a?(Hash) ? subject.values.first : subject).class
      klass == Class || klass == Module
    end

    def matches_non_block_conditions(subject)
      if @conditions.is_a?(Hash)
        return nested_subject_matches_conditions?(subject) if subject.class == Hash
        return matches_conditions_hash?(subject) unless subject_class?(subject)
      end
      # Don't stop at "cannot" definitions when there are conditions.
      conditions_empty? ? true : @base_behavior
    end

    def nested_subject_matches_conditions?(subject_hash)
      parent, _child = subject_hash.first
      matches_conditions_hash?(parent, @conditions[parent.class.name.downcase.to_sym] || {})
    end

    # Checks if the given subject matches the given conditions hash.
    # This behavior can be overriden by a model adapter by defining two class methods:
    # override_matching_for_conditions?(subject, conditions) and
    # matches_conditions_hash?(subject, conditions)
    def matches_conditions_hash?(subject, conditions = @conditions)
      return true if conditions.empty?
      adapter = model_adapter(subject)

      if adapter.override_conditions_hash_matching?(subject, conditions)
        return adapter.matches_conditions_hash?(subject, conditions)
      end

      matches_all_conditions?(adapter, conditions, subject)
    end

    def matches_all_conditions?(adapter, conditions, subject)
      conditions.all? do |name, value|
        if adapter.override_condition_matching?(subject, name, value)
          adapter.matches_condition?(subject, name, value)
        else
          condition_match?(subject.send(name), value)
        end
      end
    end

    def condition_match?(attribute, value)
      case value
      when Hash
        hash_condition_match?(attribute, value)
      when Range
        value.cover?(attribute)
      when Enumerable
        value.include?(attribute)
      else
        attribute == value
      end
    end

    def hash_condition_match?(attribute, value)
      if attribute.is_a?(Array) || (defined?(ActiveRecord) && attribute.is_a?(ActiveRecord::Relation))
        attribute.any? { |element| matches_conditions_hash?(element, value) }
      else
        attribute && matches_conditions_hash?(attribute, value)
      end
    end

    def call_block_with_all(action, subject, extra_args)
      if subject.class == Class
        @block.call(action, subject, nil, *extra_args)
      else
        @block.call(action, subject.class, subject, *extra_args)
      end
    end

    def model_adapter(subject)
      CanCan::ModelAdapters::AbstractAdapter.adapter_class(subject_class?(subject) ? subject : subject.class)
    end

    def conditions_empty?
      @conditions == {} || @conditions.nil?
    end
  end
end
