# this class is responsible for detecting sti classes and creating new rules for the
# relevant subclasses, using the inheritance_column as a merger
module CanCan
  module ModelAdapters
    class StiNormalizer
      class << self
        def normalize(rules)
          rules_cache = []
          return unless defined?(ActiveRecord::Base)

          rules.delete_if do |rule|
            subjects = rule.subjects.select do |subject|
              update_rule(subject, rule, rules_cache)
            end
            subjects.length == rule.subjects.length
          end
          rules_cache.each { |rule| rules.push(rule) }
        end

        private

        def update_rule(subject, rule, rules_cache)
          return false unless subject.respond_to?(:descends_from_active_record?)
          return false if subject == :all || subject.descends_from_active_record?
          return false unless subject < ActiveRecord::Base

          rules_cache.push(build_rule_for_subclass(rule, subject))
          true
        end

        # create a new rule for the subclasses that links on the inheritance_column
        def build_rule_for_subclass(rule, subject)
          CanCan::Rule.new(rule.base_behavior, rule.actions, subject.superclass,
                           rule.conditions.merge(subject.inheritance_column => subject.name), rule.block)
        end
      end
    end
  end
end
