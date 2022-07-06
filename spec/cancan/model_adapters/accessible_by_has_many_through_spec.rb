require 'spec_helper'

# integration tests for latest ActiveRecord version.
RSpec.describe CanCan::ModelAdapters::ActiveRecord5Adapter do
  let(:ability) { double.extend(CanCan::Ability) }
  let(:users_table) { Post.table_name }
  let(:posts_table) { Post.table_name }
  let(:likes_table) { Like.table_name }
  before :each do
    connect_db
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
    @like1 = Like.create!(post: @post1, user: @user1)
    @like2 = Like.create!(post: @post1, user: @user2)
    @editor1 = Editor.create(user: @user1, post: @post2)
    ability.can :read, Post, user_id: @user1
    ability.can :read, Post, editors: { user_id: @user1 }
  end

  CanCan.valid_accessible_by_strategies.each do |strategy|
    context "using #{strategy} strategy" do
      before :each do
        CanCan.accessible_by_strategy = strategy
      end

      describe 'preloading of associations' do
        it 'preloads associations correctly' do
          posts = Post.accessible_by(ability).where(published: true).includes(likes: :user)
          expect(posts[0].association(:likes)).to be_loaded
          expect(posts[0].likes[0].association(:user)).to be_loaded
        end
      end

      if CanCan::ModelAdapters::ActiveRecordAdapter.version_greater_or_equal?('5.0.0')
        describe 'selecting custom columns' do
          it 'extracts custom columns correctly' do
            posts = Post.accessible_by(ability).where(published: true).select('posts.title as mytitle')
            expect(posts[0].mytitle).to eq 'post1'
          end
        end
      end

      describe 'filtering of results' do
        it 'adds the where clause correctly' do
          posts = Post.accessible_by(ability).where(published: true)
          expect(posts.length).to eq 1
        end
      end
    end
  end

  unless CanCan::ModelAdapters::ActiveRecordAdapter.version_lower?('5.0.0')
    describe 'filtering of results - subquery' do
      before :each do
        CanCan.accessible_by_strategy = :subquery
      end

      it 'adds the where clause correctly with joins' do
        posts = Post.joins(:editors).where('editors.user_id': @user1.id).accessible_by(ability)
        expect(posts.length).to eq 1
      end
    end
  end

  describe 'filtering of results - left_joins' do
    before :each do
      CanCan.accessible_by_strategy = :left_join
    end

    if CanCan::ModelAdapters::ActiveRecordAdapter.version_greater_or_equal?('5.2.0')
      it 'adds the where clause correctly with joins on AR 5.2+' do
        posts = Post.joins(:editors).where('editors.user_id': @user1.id).accessible_by(ability)
        expect(posts.length).to eq 1
      end
    end

    it 'adds the where clause correctly without joins' do
      posts = Post.where('editors.user_id': @user1.id).accessible_by(ability)
      expect(posts.length).to eq 1
    end
  end
end
