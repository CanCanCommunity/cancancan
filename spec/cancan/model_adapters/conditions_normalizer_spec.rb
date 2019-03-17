require 'spec_helper'

RSpec.describe CanCan::ModelAdapters::ConditionsNormalizer do
  before do
    connect_db
    ActiveRecord::Migration.verbose = false
    ActiveRecord::Schema.define do
      create_table(:articles) do |t|
      end

      create_table(:users) do |t|
        t.string :name
      end

      create_table(:comments) do |t|
      end

      create_table(:spread_comments) do |t|
        t.integer :article_id
        t.integer :comment_id
      end

      create_table(:legacy_mentions) do |t|
        t.integer :user_id
        t.integer :article_id
      end
    end

    class Article < ActiveRecord::Base
      has_many :spread_comments
      has_many :comments, through: :spread_comments
      has_many :mentions
      has_many :mentioned_users, through: :mentions, source: :user
    end

    class Comment < ActiveRecord::Base
      has_many :spread_comments
      has_many :articles, through: :spread_comments
    end

    class SpreadComment < ActiveRecord::Base
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
  end

  it 'simplifies has_many through associations' do
    rule = CanCan::Rule.new(true, :read, Comment, articles: { mentioned_users: { name: 'pippo' } })
    CanCan::ModelAdapters::ConditionsNormalizer.normalize(Comment, [rule])
    expect(rule.conditions).to eq(spread_comments: { article: { mentions: { user: { name: 'pippo' } } } })
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
end
