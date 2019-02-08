require 'spec_helper'

# integration tests for latest ActiveRecord version.
describe CanCan::ModelAdapters::ActiveRecord5Adapter do
  let(:ability) { double.extend(CanCan::Ability) }
  let(:users_table) { Post.table_name }
  let(:posts_table) { Post.table_name }
  let(:likes_table) { Like.table_name }
  before :each do
    ActiveRecord::Base.logger = Logger.new(STDOUT)

    ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
    ActiveRecord::Migration.verbose = false

    ActiveRecord::Schema.define do
      create_table(:users) do |t|
        t.string :name
        t.timestamps null: false
      end

      create_table(:posts) do |t|
        t.string :title
        t.boolean :published, default: true
        t.integer :user_id
        t.timestamps null: false
      end

      create_table(:likes) do |t|
        t.integer :post_id
        t.integer :user_id
        t.integer :position
        t.timestamps null: false
      end

      create_table(:editors) do |t|
        t.integer :post_id
        t.integer :user_id
        t.timestamps null: false
      end
    end

    class User < ActiveRecord::Base
      has_many :posts
      has_many :likes
      has_many :editors
    end

    class Post < ActiveRecord::Base
      belongs_to :user
      has_many :likes
      has_many :editors
    end

    class Like < ActiveRecord::Base
      belongs_to :user
      belongs_to :post
    end

    class Editor < ActiveRecord::Base
      belongs_to :user
      belongs_to :post
    end
  end

  before do
    @user1 = User.create!
    @user2 = User.create!
    @post1 = Post.create!(title: 'post1', user: @user1)
    @post2 = Post.create!(user: @user1, published: false)
    @post3 = Post.create!(user: @user2)
    @like1 = Like.create!(post: @post1, user: @user1, position: 2)
    @like2 = Like.create!(post: @post1, user: @user2, position: 3)
    @like3 = Like.create!(post: @post2, user: @user2, position: 1)
    @editor1 = Editor.create(user: @user1, post: @post2)
    ability.can :read, Post, user_id: @user1
    ability.can :read, Post, editors: { user_id: @user1 }
  end

  describe 'preloading of associatons' do
    it 'preloads associations correctly' do
      posts = Post.accessible_by(ability).includes(likes: :user)
      expect(posts[0].association(:likes)).to be_loaded
      expect(posts[0].likes[0].association(:user)).to be_loaded
    end
  end

  describe 'filtering of results' do
    it 'adds the where clause correctly' do
      posts = Post.accessible_by(ability).where(published: true)
      expect(posts.length).to eq 1
    end
  end

  describe 'ordering on joined table' do
    it 'can order by a relation attribute' do
      posts = @user1.posts.accessible_by(ability).includes(:likes).order('likes.position')
      expect(posts).to eq [@post2, @post1]
    end
  end

  describe 'selecting custom columns' do
    # TODO: it currently overrides the select statement. 3.0.0 fixes it.
    xit 'extracts custom columns correctly' do
      posts = Post.accessible_by(ability).select('title as mytitle')
      expect(posts[0].mytitle).to eq 'post1'
    end
  end
end
