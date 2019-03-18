module SQLHelpers
  def normalized_sql(adapter)
    adapter.database_records.to_sql.strip.squeeze(' ')
  end

  if ActiveRecord.version >= Gem::Version.new('6.0.0.beta')
    def sqlite_true_value
      '1'
    end

    def sqlite_false_value
      '0'
    end
  else
    def sqlite_true_value
      '\'t\''
    end

    def sqlite_false_value
      '\'f\''
    end
  end
end
