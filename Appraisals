appraise 'activerecord_4.2.0' do
  gem 'activerecord', '~> 4.2.0', require: 'active_record'
  gem 'activesupport', '~> 4.2.0', require: 'active_support/all'
  gem 'actionpack', '~> 4.2.0', require: 'action_pack'
  gem 'nokogiri', '~> 1.6.8', require: 'nokogiri' # TODO: fix for ruby 2.0.0

  gemfile.platforms :jruby do
    gem 'activerecord-jdbcsqlite3-adapter', '~> 1.3.24'
    gem 'jdbc-sqlite3'
    gem 'jdbc-postgres'
  end

  gemfile.platforms :ruby, :mswin, :mingw do
    gem 'sqlite3', '~> 1.3.0'
    gem 'pg', '~> 0.21'
  end
end

appraise 'activerecord_5.0.2' do
  gem 'activerecord', '~> 5.0.2', require: 'active_record'
  gem 'activesupport', '~> 5.0.2', require: 'active_support/all'
  gem 'actionpack', '~> 5.0.2', require: 'action_pack'

  gemfile.platforms :jruby do
    gem 'activerecord-jdbcsqlite3-adapter'
    gem 'jdbc-sqlite3'
    gem 'jdbc-postgres'
  end

  gemfile.platforms :ruby, :mswin, :mingw do
    gem 'sqlite3', '~> 1.3.0'
    gem 'pg', '~> 0.21'
  end
end

appraise 'activerecord_5.1.0' do
  gem 'activerecord', '~> 5.1.0', require: 'active_record'
  gem 'activesupport', '~> 5.1.0', require: 'active_support/all'
  gem 'actionpack', '~> 5.1.0', require: 'action_pack'

  gemfile.platforms :jruby do
    gem 'activerecord-jdbcsqlite3-adapter'
    gem 'jdbc-sqlite3'
    gem 'jdbc-postgres'
  end

  gemfile.platforms :ruby, :mswin, :mingw do
    gem 'sqlite3', '~> 1.3.0'
    gem 'pg', '~> 0.21'
  end
end

appraise 'activerecord_5.2.2' do
  gem 'activerecord', '~> 5.2.2', require: 'active_record'
  gem 'activesupport', '~> 5.2.2', require: 'active_support/all'
  gem 'actionpack', '~> 5.2.2', require: 'action_pack'

  gemfile.platforms :jruby do
    gem 'activerecord-jdbcsqlite3-adapter'
    gem 'jdbc-sqlite3'
    gem 'jdbc-postgres'
  end

  gemfile.platforms :ruby, :mswin, :mingw do
    gem 'sqlite3', '~> 1.3.0'
    gem 'pg', '~> 0.21'
  end
end

appraise 'activerecord_6.0.0' do
  gem 'actionpack', '~> 6.0.0.beta1', require: 'action_pack'
  gem 'activerecord', '~> 6.0.0.beta1', require: 'active_record'
  gem 'activesupport', '~> 6.0.0.beta1', require: 'active_support/all'

  platforms :jruby do
    gem 'activerecord-jdbcsqlite3-adapter'
    gem 'jdbc-sqlite3'
    gem 'jdbc-postgres'
  end

  platforms :ruby, :mswin, :mingw do
    gem 'pg', '~> 1.1.4'
    gem 'sqlite3', '~> 1.3.0'
  end
end
