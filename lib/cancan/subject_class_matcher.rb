# This class is responsible for matching classes and their subclasses as well as
# upmatching classes to their ancestors.
# This is used to generate sti connections
class SubjectClassMatcher
  def initialize
    @subclasses = {}
  end

  def matches_subject_class?(subjects, subject)
    has_subclasses = subject.respond_to?(:subclasses)

    subjects.any? do |sub|
      matching_class_check(subject, sub, has_subclasses)
    end
  end

  private

  def matching_class_check(subject, sub, has_subclasses)
    matches = matches_class_or_is_related(subject, sub)
    if has_subclasses
      store_subclasses(subject.class.name, subject.subclasses)
      matches || subject_subclasses(subject.class.name).include?(sub)
    else
      matches
    end
  end

  def store_subclasses(name, subclasses)
    @subclasses[name] ||= subclasses
  end

  def subject_subclasses(name)
    @subclasses[name]
  end

  def matches_class_or_is_related(subject, sub)
    sub.is_a?(Module) && (subject.is_a?(sub) ||
        subject.class.to_s == sub.to_s ||
        (subject.is_a?(Module) && subject.ancestors.include?(sub)))
  end
end
