appraise 'activerecord_4.2' do
  gem 'activerecord', '~> 4.2.0', require: 'active_record'
  gem 'activesupport', '~> 4.2.0', require: 'active_support/all'
  gem 'actionpack', '~> 4.2.0', require: 'action_pack'
  gem 'nokogiri', '~> 1.6.8', require: 'nokogiri' # TODO: fix for ruby 2.0.0

  gemfile.platforms :jruby do
    gem 'activerecord-jdbcsqlite3-adapter'
    gem 'jdbc-sqlite3'
  end

  gemfile.platforms :ruby, :mswin, :mingw do
    gem 'sqlite3'
    gem 'pg'
  end
end

appraise 'activerecord_5.0.2' do
  gem 'activerecord', '~> 5.0.2', require: 'active_record'
  gem 'activesupport', '~> 5.0.2', require: 'active_support/all'
  gem 'actionpack', '~> 5.0.2', require: 'action_pack'

  gemfile.platforms :jruby do
    gem 'activerecord-jdbcsqlite3-adapter'
    gem 'jdbc-sqlite3'
  end

  gemfile.platforms :ruby, :mswin, :mingw do
    gem 'sqlite3'
    gem 'pg'
  end
end

appraise 'activerecord_5.1.0' do
  gem 'activerecord', '~> 5.1.0', require: 'active_record'
  gem 'activesupport', '~> 5.1.0', require: 'active_support/all'
  gem 'actionpack', '~> 5.1.0', require: 'action_pack'

  gemfile.platforms :jruby do
    gem 'activerecord-jdbcsqlite3-adapter'
    gem 'jdbc-sqlite3'
  end

  gemfile.platforms :ruby, :mswin, :mingw do
    gem 'sqlite3'
    gem 'pg'
  end
end
