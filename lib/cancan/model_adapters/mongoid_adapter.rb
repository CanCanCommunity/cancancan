module CanCan
  module ModelAdapters
    class MongoidAdapter < AbstractAdapter
      def self.for_class?(model_class)
        model_class <= Mongoid::Document
      end

      def self.override_conditions_hash_matching?(subject, conditions)
        conditions.any? do |k,v|
          key_is_not_symbol = lambda { !k.kind_of?(Symbol) }
          subject_value_is_array = lambda do
            subject.respond_to?(k) && subject.send(k).is_a?(Array)
          end

          key_is_not_symbol.call || subject_value_is_array.call
        end
      end

      def self.matches_conditions_hash?(subject, conditions)
        # To avoid hitting the db, retrieve the raw Mongo selector from
        # the Mongoid Criteria and use Mongoid::Matchers#matches?
        subject.matches?( subject.class.where(conditions).selector )
      end
      
      if defined? Mongoid::VERSION and Mongoid::VERSION > '5'

        def database_records
          if @rules.size == 0
            @model_class.where(:_id => {'$exists' => false, '$type' => 7}) # return no records in Mongoid
          elsif @rules.size == 1 && @rules[0].conditions.is_a?(Mongoid::Criteria)
            @rules[0].conditions
          else
            # we only need to process can rules if
            # there are no rules with empty conditions
            rules = @rules.reject { |rule| rule.conditions.empty? && rule.base_behavior }
            process_can_rules = @rules.count == rules.count

            or_conditions = []
            exclude_conditions = []
            united_conditions = {}

            rules.each do |rule|
              if process_can_rules && rule.base_behavior
                or_conditions << simplify_relations(@model_class, rule.conditions)
              elsif !rule.base_behavior
                exclude_conditions << simplify_relations(@model_class, rule.conditions, true)
              end
            end

            united_conditions['$or'] = or_conditions if or_conditions.any?
            united_conditions['$and'] = exclude_conditions if exclude_conditions.any?

            if @model_class.all.selector.any?
              @model_class.all.and united_conditions
            else
              @model_class.where united_conditions
            end
          end
        end

      else

        def database_records
          if @rules.size == 0
            @model_class.where(:_id => {'$exists' => false, '$type' => 7}) # return no records in Mongoid
          elsif @rules.size == 1 && @rules[0].conditions.is_a?(Mongoid::Criteria)
            @rules[0].conditions
          else
            # we only need to process can rules if
            # there are no rules with empty conditions
            rules = @rules.reject { |rule| rule.conditions.empty? && rule.base_behavior }
            process_can_rules = @rules.count == rules.count

            rules.inject(@model_class.all) do |records, rule|
              if process_can_rules && rule.base_behavior
                records.or simplify_relations(@model_class, rule.conditions)
              elsif !rule.base_behavior
                records.excludes simplify_relations(@model_class, rule.conditions)
              else
                records
              end
            end
          end
        end

      end

      private
      # Look for criteria on relations and replace with simple id queries
      # eg.
      # {user: {:tags.all => []}} becomes {"user_id" => {"$in" => [__, ..]}}
      # {user: {:session => {:tags.all => []}}} becomes {"user_id" => {"session_id" => {"$in" => [__, ..]} }}
      def simplify_relations model_class, conditions, negation=false
        model_relations = model_class.relations.with_indifferent_access
        Hash[
          conditions.map {|k,v|
            if relation = model_relations[k]
              relation_class_name = relation[:class_name].blank? ? k.to_s.classify : relation[:class_name]
              v = simplify_relations(relation_class_name.constantize, v)
              relation_ids = relation_class_name.constantize.where(v).only(:id).map(&:id)
              k = "#{k}_id"
              if negation
                v = { "$nin" => relation_ids }
              else
                v = { "$in" => relation_ids }
              end
            elsif negation
              v = { "$ne" => v }
            end
            [k,v]
          }
        ]
      end
    end
  end
end

# simplest way to add `accessible_by` to all Mongoid Documents
module Mongoid::Document::ClassMethods
  include CanCan::ModelAdditions::ClassMethods
end
