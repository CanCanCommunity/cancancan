# this class is responsible for detecting sti classes and creating new rules for the
# relevant subclasses, using the inheritance_column as a merger
module CanCan
  module ModelAdapters
    class StiNormalizer
      class << self
        def normalize(rules)
          rules_cache = []
          rules.delete_if.with_index do |rule, _index|
            subjects = rule.subjects.select do |subject|
              next if subject == :all || subject.descends_from_active_record?

              rules_cache.push(build_rule_for_subclass(rule, subject))
              true
            end
            subjects.length == rule.subjects.length
          end
          rules_cache.each { |rule| rules.push(rule) }
        end

        private

        # create a new rule for the subclasses that links on the inheritance_column
        def build_rule_for_subclass(rule, subject)
          CanCan::Rule.new(rule.base_behavior, rule.actions, subject.superclass,
                           rule.conditions.merge(subject.inheritance_column => subject.name), rule.block)
        end
      end
    end
  end
end
