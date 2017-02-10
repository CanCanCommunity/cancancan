require 'spec_helper'

if defined? CanCan::ModelAdapters::SequelAdapter
  describe CanCan::ModelAdapters::SequelAdapter do
    DB = if RUBY_PLATFORM == 'java'
           Sequel.connect('jdbc:sqlite:db.sqlite3')
         else
           Sequel.sqlite
         end

    DB.create_table :users do
      primary_key :id
      String :name
    end

    class User < Sequel::Model
      one_to_many :articles
    end

    DB.create_table :articles do
      primary_key :id
      String :name
      TrueClass :published
      TrueClass :secret
      Integer :priority
      foreign_key :user_id, :users
    end

    class Article < Sequel::Model
      many_to_one :user
      one_to_many :comments
    end

    DB.create_table :comments do
      primary_key :id
      TrueClass :spam
      foreign_key :article_id, :articles
    end

    class Comment < Sequel::Model
      many_to_one :article
    end

    before(:each) do
      Comment.dataset.delete
      Article.dataset.delete
      User.dataset.delete
      (@ability = double).extend(CanCan::Ability)
    end

    it 'should be for only sequel model classes' do
      expect(CanCan::ModelAdapters::SequelAdapter).to_not be_for_class(Object)
      expect(CanCan::ModelAdapters::SequelAdapter).to be_for_class(Article)
      expect(CanCan::ModelAdapters::AbstractAdapter.adapter_class(Article)).to eq CanCan::ModelAdapters::SequelAdapter
    end

    it 'should find record' do
      article = Article.create
      expect(CanCan::ModelAdapters::SequelAdapter.find(Article, article.id)).to eq article
    end

    it 'should not fetch any records when no abilities are defined' do
      Article.create
      expect(Article.accessible_by(@ability).all).to be_empty
    end

    it 'should fetch all articles when one can read all' do
      @ability.can :read, Article
      article = Article.create
      expect(Article.accessible_by(@ability).all).to eq [article]
    end

    it 'should fetch only the articles that are published' do
      @ability.can :read, Article, published: true
      article1 = Article.create(published: true)
      Article.create(published: false)
      expect(Article.accessible_by(@ability).all).to eq [article1]
    end

    it 'should fetch any articles which are published or secret' do
      @ability.can :read, Article, published: true
      @ability.can :read, Article, secret: true
      article1 = Article.create(published: true, secret: false)
      article2 = Article.create(published: true, secret: true)
      article3 = Article.create(published: false, secret: true)
      Article.create(published: false, secret: false)
      expect(Article.accessible_by(@ability).all).to eq([article1, article2, article3])
    end

    it 'should fetch only the articles that are published and not secret' do
      @ability.can :read, Article, published: true
      @ability.cannot :read, Article, secret: true
      article1 = Article.create(published: true, secret: false)
      Article.create(published: true, secret: true)
      Article.create(published: false, secret: true)
      Article.create(published: false, secret: false)
      expect(Article.accessible_by(@ability).all).to eq [article1]
    end

    it 'should only read comments for articles which are published' do
      @ability.can :read, Comment, article: { published: true }
      comment1 = Comment.create(article: Article.create(published: true))
      Comment.create(article: Article.create(published: false))
      expect(Comment.accessible_by(@ability).all).to eq [comment1]
    end

    it "should only read comments for articles which are published and user is 'me'" do
      @ability.can :read, Comment, article: { user: { name: 'me' }, published: true }
      user1 = User.create(name: 'me')
      comment1 = Comment.create(article: Article.create(published: true, user: user1))
      Comment.create(article: Article.create(published: true))
      Comment.create(article: Article.create(published: false, user: user1))
      expect(Comment.accessible_by(@ability).all).to eq [comment1]
    end

    it 'should allow conditions in SQL and merge with hash conditions' do
      @ability.can :read, Article, published: true
      @ability.can :read, Article, ['secret=?', true], &:secret
      @ability.cannot :read, Article, 'priority > 1' do |article|
        article.priority > 1
      end
      article1 = Article.create(published: true, secret: false, priority: 1)
      article2 = Article.create(published: true, secret: true, priority: 1)
      Article.create(published: true, secret: true, priority: 2)
      Article.create(published: false, secret: false, priority: 2)
      expect(Article.accessible_by(@ability).all).to eq [article1, article2]
    end
  end
end
