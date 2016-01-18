appraise "activerecord_3.2" do
  gem "activerecord", "~> 3.2.0", :require => "active_record"

  gemfile.platforms :jruby do
    gem "activerecord-jdbcsqlite3-adapter"
    gem "jdbc-sqlite3"
  end

  gemfile.platforms :ruby, :mswin, :mingw do
    gem "sqlite3"
  end
end

appraise "activerecord_4.0" do
  gem "activerecord", "~> 4.0.5", :require => "active_record"
  gem "activesupport", "~> 4.0.5", :require => "active_support/all"

  gemfile.platforms :jruby do
    gem "activerecord-jdbcsqlite3-adapter"
    gem "jdbc-sqlite3"
  end

  gemfile.platforms :ruby, :mswin, :mingw do
    gem "sqlite3"
  end
end

appraise "activerecord_4.1" do
  gem "activerecord", "~> 4.1.1", :require => "active_record"
  gem "activesupport", "~> 4.1.1", :require => "active_support/all"

  gemfile.platforms :jruby do
    gem "activerecord-jdbcsqlite3-adapter"
    gem "jdbc-sqlite3"
  end

  gemfile.platforms :ruby, :mswin, :mingw do
    gem "sqlite3"
  end
end

appraise "activerecord_4.2" do
  gem "activerecord", "~> 4.2.0", :require => "active_record"
  gem 'activesupport', '~> 4.2.0', :require => 'active_support/all'

  gemfile.platforms :jruby do
    gem "activerecord-jdbcsqlite3-adapter"
    gem "jdbc-sqlite3"
  end

  gemfile.platforms :ruby, :mswin, :mingw do
    gem "sqlite3"
    gem "pg"
  end
end

appraise "activerecord_5.0" do
  gem "activerecord", "~> 5.0.0.beta1", :require => "active_record"
  gem 'activesupport', '~> 5.0.0.beta1', :require => 'active_support/all'

  gemfile.platforms :jruby do
    gem "activerecord-jdbcsqlite3-adapter"
    gem "jdbc-sqlite3"
  end

  gemfile.platforms :ruby, :mswin, :mingw do
    gem "sqlite3"
    gem "pg"
  end
end

appraise "mongoid_2.x" do
  gem "activesupport", "~> 3.0", :require => "active_support/all"
  gem "mongoid", "~> 2.0.0"

  gemfile.platforms :ruby, :mswin, :mingw do
    gem "bson_ext", "~> 1.1"
  end

  gemfile.platforms :jruby do
    gem "mongo", "~> 1.9.2"
  end
end

appraise "sequel_3.x" do
  gem "sequel", "~> 3.47.0"
  gem "activesupport", "~> 3.0", :require => "active_support/all"

  gemfile.platforms :jruby do
    gem "jdbc-sqlite3"
  end

  gemfile.platforms :ruby, :mswin, :mingw do
    gem "sqlite3"
  end
end
