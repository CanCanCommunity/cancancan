module SQLHelpers
  def normalized_sql(adapter)
    adapter.database_records.to_sql.strip.squeeze(' ')
  end
end
