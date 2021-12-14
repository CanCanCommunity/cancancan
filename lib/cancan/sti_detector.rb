class StiDetector
  def self.sti_class?(subject)
    return false unless defined?(ActiveRecord::Base)

    sti_column = subject.inheritance_column
    subject.public_send(sti_column).present? && subject.has_attribute?(sti_column)
  rescue StandardError
    false
  end
end
