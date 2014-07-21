require "spec_helper"

if defined? CanCan::ModelAdapters::ActiveRecord4Adapter
  describe CanCan::ModelAdapters::ActiveRecord4Adapter do
    before :each do
      ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")
      ActiveRecord::Migration.verbose = false
      ActiveRecord::Schema.define do
        create_table(:users) do |t|
          t.timestamps
        end

        create_table(:articles) do |t|
          t.timestamps
          t.integer :user_id
        end
      end
      (@ability = double).extend(CanCan::Ability)
    end

    it "respects scope on included associations" do
      class User < ActiveRecord::Base
        has_many :articles, lambda { order("articles.id DESC") }
      end

      class Article < ActiveRecord::Base
        belongs_to :user
      end

      @ability.can :read, [User, Article]

      user = User.create!
      article1 = Article.create!(:user => user, :created_at => 1.hours.ago)
      article2 = Article.create!(:user => user, :created_at => 2.hours.ago)

      expect(User.accessible_by(@ability).order('users.created_at ASC').includes(:articles).first.articles).to eq [article2, article1]
    end
  end
end
