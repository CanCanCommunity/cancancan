require 'spec_helper'

RSpec.describe CanCan::ModelAdapters::ConditionsNormalizer do
  before do
    connect_db
    ActiveRecord::Migration.verbose = false
    ActiveRecord::Schema.define do
      create_table(:articles, force: true) do |t|
      end

      create_table(:users, force: true) do |t|
        t.string :name
      end

      create_table(:comments, force: true) do |t|
      end

      create_table(:spread_comments, force: true) do |t|
        t.integer :article_id
        t.integer :comment_id
      end

      create_table(:legacy_mentions, force: true) do |t|
        t.integer :user_id
        t.integer :article_id
      end

      create_table(:attachments, force: true) do |t|
        t.references :record, polymorphic: true
        t.integer :blob_id
      end

      create_table(:blob, force: true) do |t|
      end
    end

    class Article < ActiveRecord::Base
      self.record_timestamps = false

      has_many :spread_comments
      has_many :comments, through: :spread_comments
      has_many :mentions
      has_many :mentioned_users, through: :mentions, source: :user
      has_many :attachments, as: :record
    end

    class Comment < ActiveRecord::Base
      self.record_timestamps = false

      has_many :spread_comments
      has_many :articles, through: :spread_comments
    end

    class SpreadComment < ActiveRecord::Base
      self.record_timestamps = false

      belongs_to :comment
      belongs_to :article
    end

    class Mention < ActiveRecord::Base
      self.table_name = 'legacy_mentions'
      belongs_to :article
      belongs_to :user
    end

    class User < ActiveRecord::Base
      has_many :mentions
      has_many :mentioned_articles, through: :mentions, source: :article
    end

    class Attachment < ActiveRecord::Base
      belongs_to :record, polymorphic: true
      belongs_to :blob
    end

    class Blob < ActiveRecord::Base
      has_many :attachments
      has_many :articles, through: :attachments, source: :record, source_type: 'Article'
    end
  end

  it 'simplifies has_many through associations' do
    rule = CanCan::Rule.new(true, :read, Comment, articles: { mentioned_users: { name: 'pippo' } })
    CanCan::ModelAdapters::ConditionsNormalizer.normalize(Comment, [rule])
    expect(rule.conditions).to eq(spread_comments: { article: { mentions: { user: { name: 'pippo' } } } })
  end

  it 'does not simplifies has_many through polymorphic associations' do
    rule = CanCan::Rule.new(true, :read, Blob, articles: { id: 11 })
    CanCan::ModelAdapters::ConditionsNormalizer.normalize(Blob, [rule])
    expect(rule.conditions).to eq(articles: { id: 11 })
  end

  it 'normalizes the has_one through associations' do
    class Supplier < ActiveRecord::Base
      has_one :accountant
      has_one :account_history, through: :accountant
    end

    class Accountant < ActiveRecord::Base
      belongs_to :supplier
      has_one :account_history
    end

    class AccountHistory < ActiveRecord::Base
      belongs_to :accountant
    end

    rule = CanCan::Rule.new(true, :read, Supplier, account_history: { name: 'pippo' })
    CanCan::ModelAdapters::ConditionsNormalizer.normalize(Supplier, [rule])
    expect(rule.conditions).to eq(accountant: { account_history: { name: 'pippo' } })
  end

  context 'with accessible_by using has_many-through conditions' do
    let(:ability) { double.extend(CanCan::Ability) }

    before do
      @article1 = Article.create!
      @comment1 = Comment.create!
      SpreadComment.create!(article: @article1, comment: @comment1)
    end

    it 'does not overwrite shared rule conditions after accessible_by is called' do
      # Regression test for issue #876.
      # accessible_by triggers ConditionsNormalizer which expands has_many-through conditions
      # and writes the result back to rule.conditions on the shared Rule object.
      # Without the adapter fix, the shared Rule's conditions are permanently replaced,
      # breaking future can? checks that rely on the original un-normalized conditions.
      ability.can :read, Comment, articles: { id: @article1.id }
      rule = ability.send(:rules).last
      conditions_before_accessible_by = rule.conditions

      Comment.accessible_by(ability)

      # The shared Rule object must not have its conditions replaced.
      # Without the fix: rule.conditions becomes { spread_comments: { article: { id: ... } } }.
      # With the fix: rule.conditions is still the original hash object.
      expect(rule.conditions).to be(conditions_before_accessible_by)
    end
  end
end
