# This class is responsible for matching classes and their subclasses as well as
# upmatching classes to their ancestors.
# This is used to generate sti connections
class SubjectClassMatcher
  def self.matches_subject_class?(subjects, subject)
    subjects.any? do |sub|
      matching_class_check(subject, sub)
    end
  end

  def self.matching_class_check(subject, sub)
    matches_class_or_is_related(subject, sub)
  end

  def self.matches_class_or_is_related(subject, sub)
    return false unless sub.is_a?(Module)

    (subject.is_a?(sub) ||
        subject.class.to_s == sub.to_s ||
        (subject.is_a?(Module) && subject.ancestors.include?(sub)))
  end
end
