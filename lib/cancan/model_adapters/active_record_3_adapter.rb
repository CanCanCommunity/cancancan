module CanCan
  module ModelAdapters
    class ActiveRecord3Adapter < AbstractAdapter
      include ActiveRecordAdapter
      def self.for_class?(model_class)
        model_class <= ActiveRecord::Base
      end

      def self.override_condition_matching?(subject, name, value)
        name.kind_of?(MetaWhere::Column) if defined? MetaWhere
      end

      def self.matches_condition?(subject, name, value)
        subject_value = subject.send(name.column)
        if name.method.to_s.ends_with? "_any"
          value.any? { |v| meta_where_match? subject_value, name.method.to_s.sub("_any", ""), v }
        elsif name.method.to_s.ends_with? "_all"
          value.all? { |v| meta_where_match? subject_value, name.method.to_s.sub("_all", ""), v }
        else
          meta_where_match? subject_value, name.method, value
        end
      end

      def self.meta_where_match?(subject_value, method, value)
        case method.to_sym
        when :eq      then subject_value == value
        when :not_eq  then subject_value != value
        when :in      then value.include?(subject_value)
        when :not_in  then !value.include?(subject_value)
        when :lt      then subject_value < value
        when :lteq    then subject_value <= value
        when :gt      then subject_value > value
        when :gteq    then subject_value >= value
        when :matches then subject_value =~ Regexp.new("^" + Regexp.escape(value).gsub("%", ".*") + "$", true)
        when :does_not_match then !meta_where_match?(subject_value, :matches, value)
        else raise NotImplemented, "The #{method} MetaWhere condition is not supported."
        end
      end

      private

      def build_relation(*where_conditions)
        @model_class.where(*where_conditions).includes(joins)
      end
    end
  end
end
