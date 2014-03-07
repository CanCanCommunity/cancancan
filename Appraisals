appraise "rails_3.0" do
  gem "activerecord", "~> 3.0.20", :require => "active_record"
  gem "with_model", "~> 0.2.5"
  gem "meta_where"

  gemfile.platforms :jruby do
    gem "activerecord-jdbcsqlite3-adapter"
    gem "jdbc-sqlite3"
  end

  gemfile.platforms :ruby, :mswin, :mingw do
    gem "sqlite3"
  end
end

appraise "rails_3.0_datamapper" do
  gem "dm-core", "~> 1.0.2"
  gem "dm-sqlite-adapter", "~> 1.0.2"
  gem "dm-migrations", "~> 1.0.2"
end

appraise "rails_3.0_mongoid" do
  gem "mongoid", "~> 2.0.0"

  gemfile.platforms :ruby, :mswin, :mingw do
    gem "bson_ext", "~> 1.1"
  end
end
