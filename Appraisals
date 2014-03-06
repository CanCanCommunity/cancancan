appraise "rails 3 activerecord" do
  gem "activerecord", "~> 3.0.20"
  gem "supermodel", "~> 0.1.6"
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

appraise "rails 3 datamapper" do
  gem "dm-core", "~> 1.0.2"
  gem "dm-sqlite-adapter", "~> 1.0.2"
  gem "dm-migrations", "~> 1.0.2"
end

appraise "rails 3 mongoid" do
  gem "bson_ext", "~> 1.1"
  gem "mongoid", "~> 2.0.0.beta.20"
end
