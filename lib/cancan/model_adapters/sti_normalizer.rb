# this class is responsible of normalizing the hash of conditions
# by exploding has_many through associations
# when a condition is defined with an has_many through association this is exploded in all its parts
# TODO: it could identify STI and normalize it
module CanCan
  module ModelAdapters
    class StiNormalizer
      class << self
        def normalize(rules)
          rules_cache = []
          rules.delete_if.with_index do |rule, _index|
            subjects = rule.subjects.select do |subject|
              next if subject == :all || subject.descends_from_active_record?

              rules_cache.push(build_new_rule(rule, subject))
              true
            end
            subjects.length == rule.subjects.length
          end
          rules_cache.each { |rule| rules.push(rule) }
        end

        private

        def build_new_rule(rule, subject)
          CanCan::Rule.new(rule.base_behavior, rule.actions, subject.superclass,
                           rule.conditions.merge(subject.inheritance_column => subject.name), rule.block)
        end
      end
    end
  end
end
