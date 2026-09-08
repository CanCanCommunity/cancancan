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
    gem 'pg', '~> 1.3.4'
    gem 'sqlite3', '~> 1.7.3'
  end
end

appraise 'activerecord_6.0.0' do
  gem 'actionpack', '~> 6.0.0', require: 'action_pack'
  gem 'activerecord', '~> 6.0.0', require: 'active_record'
  gem 'activesupport', '~> 6.0.0', require: 'active_support/all'

  platforms :jruby do
    gem 'activerecord-jdbcsqlite3-adapter'
    gem 'jdbc-sqlite3'
    gem 'jdbc-postgres'
  end

  platforms :ruby, :mswin, :mingw do
    gem 'pg', '~> 1.3.4'
    gem 'sqlite3', '~> 1.7.3'
  end
end

appraise 'activerecord_6.1.0' do
  gem 'actionpack', '~> 6.1.0', require: 'action_pack'
  gem 'activerecord', '~> 6.1.0', require: 'active_record'
  gem 'activesupport', '~> 6.1.0', require: 'active_support/all'

  platforms :jruby do
    gem 'activerecord-jdbcsqlite3-adapter'
    gem 'jdbc-sqlite3'
    gem 'jdbc-postgres'
  end

  platforms :ruby, :mswin, :mingw do
    gem 'pg', '~> 1.3.4'
    gem 'sqlite3', '~> 1.7.3'
  end
end

appraise 'activerecord_7.0.0' do
  gem 'actionpack', '~> 7.0.0', require: 'action_pack'
  gem 'activerecord', '~> 7.0.0', require: 'active_record'
  gem 'activesupport', '~> 7.0.0', require: 'active_support/all'

  platforms :jruby do
    gem 'activerecord-jdbcsqlite3-adapter'
    gem 'jdbc-sqlite3'
    gem 'jdbc-postgres'
  end

  platforms :ruby, :mswin, :mingw do
    gem 'pg', '~> 1.3.4'
    gem 'sqlite3', '~> 1.7.3'
  end
end

appraise 'activerecord_7.1.0' do
  gem 'actionpack', '~> 7.1.0', require: 'action_pack'
  gem 'activerecord', '~> 7.1.0', require: 'active_record'
  gem 'activesupport', '~> 7.1.0', require: 'active_support/all'

  platforms :jruby do
    gem 'activerecord-jdbcsqlite3-adapter'
    gem 'jdbc-sqlite3'
    gem 'jdbc-postgres'
  end

  platforms :ruby, :mswin, :mingw do
    gem 'pg', '~> 1.5.6'
    gem 'sqlite3', '~> 1.7.3'
  end
end

appraise 'activerecord_main' do
  git 'https://github.com/rails/rails', branch: 'main' do
    gem 'actionpack', require: 'action_pack'
    gem 'activerecord', require: 'active_record'
    gem 'activesupport', require: 'active_support/all'
  end

  platforms :jruby do
    gem 'activerecord-jdbcsqlite3-adapter'
    gem 'jdbc-sqlite3'
    gem 'jdbc-postgres'
  end

  platforms :ruby, :mswin, :mingw do
    gem 'pg', '~> 1.5.6'
    gem 'sqlite3', '>= 2.0'
  end
end
