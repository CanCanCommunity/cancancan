# frozen_string_literal: true

module SQLHelpers
  def normalized_sql(adapter)
    adapter.database_records.to_sql.strip.squeeze(' ')
  end

  def connect_db
    # ActiveRecord::Base.logger = Logger.new(STDOUT)
    ActiveRecord::Base.logger = nil
    if ENV['DB'] == 'sqlite'
      ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
    elsif ENV['DB'] == 'postgres'
      connect_postgres
    elsif ENV['DB'].nil?
      raise StandardError, "ENV['DB'] not specified"
    else
      raise StandardError, "database not supported: #{ENV['DB']}.  Try DB='sqlite' or DB='postgres'"
    end
  end

  private

  def connect_postgres
    ActiveRecord::Base.establish_connection(adapter: 'postgresql', host: 'localhost',
                                            database: 'postgres', schema_search_path: 'public')
    ActiveRecord::Base.connection.drop_database('cancan_postgresql_spec')
    ActiveRecord::Base.connection.create_database('cancan_postgresql_spec', 'encoding' => 'utf-8',
                                                                            'adapter' => 'postgresql')
    ActiveRecord::Base.establish_connection(adapter: 'postgresql', host: 'localhost',
                                            database: 'cancan_postgresql_spec')
  end
end
