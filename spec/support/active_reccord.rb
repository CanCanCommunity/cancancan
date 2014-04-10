if defined? CanCan::ModelAdapters::ActiveRecordAdapter

  ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")

  ActiveRecord::Base.connection.create_table(:categories) do |t|
    t.timestamps
  end

  ActiveRecord::Base.connection.create_table(:projects) do |t|
    t.string :name
    t.timestamps
  end

  ActiveRecord::Base.connection.create_table(:sup_projects) do |t|
    t.string :name
    t.timestamps
  end

  RSpec.configure do |config|

    config.before(:each) do
      Project.delete_all
    end

  end

  class Category < ActiveRecord::Base
    has_many :projects
    has_many :articles
  end

  class Project < ActiveRecord::Base
    belongs_to :category
  end

  module Sub
    class Project < ActiveRecord::Base
      belongs_to :category
    end
  end

end
