# frozen_string_literal: true

# Rails 7.0 introduced `enum :name, values` and Rails 8.0 removed the keyword form.
module EnumHelpers
  def define_enum(name, values)
    if CanCan::ModelAdapters::ActiveRecordAdapter.version_greater_or_equal?('7.0.0')
      enum(name, values)
    else
      enum(name => values)
    end
  end
end

ActiveRecord::Base.extend(EnumHelpers) if defined?(ActiveRecord)
