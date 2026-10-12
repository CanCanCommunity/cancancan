require_relative '../sti_detector'

# this class is responsible for detecting sti classes and creating new rules for the
# relevant subclasses, using the inheritance_column as a merger
module CanCan
  module ModelAdapters
    class StiNormalizer
      class << self
        def normalize(rules)
          return unless defined?(ActiveRecord::Base)

          rules.replace(rules.flat_map { |rule| normalized_rules(rule) })
        end

        private

        # The rules for the subclasses take the place of the original rule, so their precedence is kept.
        def normalized_rules(rule)
          sti_subjects = rule.subjects.select { |subject| StiDetector.sti_class?(subject) }
          subclass_rules = sti_subjects.map { |subject| build_rule_for_subclass(rule, subject) }
          sti_subjects.length == rule.subjects.length ? subclass_rules : [rule, *subclass_rules]
        end

        # create a new rule for the subclasses that links on the inheritance_column
        def build_rule_for_subclass(rule, subject)
          sti_conditions = { subject.inheritance_column => subject.sti_name }
          new_rule_conditions =
            if rule.with_scope?
              rule.conditions.where(sti_conditions)
            else
              rule.conditions.merge(sti_conditions)
            end

          CanCan::Rule.new(rule.base_behavior, rule.actions, subject.superclass,
                           new_rule_conditions, rule.block)
        end
      end
    end
  end
end
