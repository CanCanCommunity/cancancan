require 'spec_helper'

if defined? CanCan::ModelAdapters::ConditionsExtractor
  RSpec.describe CanCan::ModelAdapters::ConditionsExtractor do
    before do
      ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
      ActiveRecord::Migration.verbose = false
      ActiveRecord::Schema.define do
        create_table(:categories) do |t|
          t.string :name
          t.boolean :visible
          t.timestamps null: false
        end

        create_table(:projects) do |t|
          t.string :name
          t.timestamps null: false
        end

        create_table(:articles) do |t|
          t.string :name
          t.timestamps null: false
          t.boolean :published
          t.boolean :secret
          t.integer :priority
          t.integer :category_id
          t.integer :user_id
        end

        create_table(:comments) do |t|
          t.boolean :spam
          t.integer :article_id
          t.timestamps null: false
        end

        create_table(:legacy_mentions) do |t|
          t.integer :user_id
          t.integer :article_id
          t.timestamps null: false
        end

        create_table(:users) do |t|
          t.timestamps null: false
        end

        create_table(:transactions) do |t|
          t.integer :sender_id
          t.integer :receiver_id
          t.integer :supervisor_id
        end
      end

      class Project < ActiveRecord::Base
      end

      class Category < ActiveRecord::Base
        has_many :articles
      end

      class Article < ActiveRecord::Base
        belongs_to :category
        has_many :comments
        has_many :mentions
        has_many :mentioned_users, through: :mentions, source: :user
        belongs_to :user
      end

      class Mention < ActiveRecord::Base
        self.table_name = 'legacy_mentions'
        belongs_to :user
        belongs_to :article
      end

      class Comment < ActiveRecord::Base
        belongs_to :article
      end

      class User < ActiveRecord::Base
        has_many :articles
        has_many :mentions
        has_many :mentioned_articles, through: :mentions, source: :article
      end

      class Transaction < ActiveRecord::Base
        belongs_to :sender, class_name: 'User', foreign_key: :sender_id
        belongs_to :receiver, class_name: 'User', foreign_key: :receiver_id
        belongs_to :supervisor, class_name: 'User', foreign_key: :supervisor_id
      end
    end

    describe 'converts hash of conditions into database sql where format' do
      it 'converts a simple association' do
        conditions = described_class.new(User).tableize_conditions(articles: { id: 1 })
        expect(conditions).to eq(articles: { id: 1 })
      end

      it 'converts a nested association' do
        conditions = described_class.new(User).tableize_conditions(articles: { category: { id: 1 } })
        expect(conditions).to eq(categories: { id: 1 })
      end

      it 'converts two associations' do
        conditions = described_class.new(User).tableize_conditions(articles: { id: 2, category: { id: 1 } })
        expect(conditions).to eq(articles: { id: 2 }, categories: { id: 1 })
      end

      it 'converts has_many through' do
        conditions = described_class.new(Article).tableize_conditions(mentioned_users: { id: 1 })
        expect(conditions).to eq(users: { id: 1 })
      end

      it 'converts associations named differently from the table' do
        conditions = described_class.new(Transaction).tableize_conditions(sender: { id: 1 })
        expect(conditions).to eq(users: { id: 1 })
      end

      it 'converts associations properly when the same table is referenced twice' do
        conditions = described_class.new(Transaction).tableize_conditions(sender: { id: 1 }, receiver: { id: 2 })
        expect(conditions).to eq(users: { id: 1 }, receivers_transactions: { id: 2 })
      end

      it 'converts very complex nested sets' do
        original_conditions = { user: { id: 1 },
                                mentioned_users: { name: 'a name',
                                                   mentioned_articles: { id: 2 },
                                                   articles: { user: { name: 'deep' },
                                                               mentioned_users: { name: 'd2' } } } }

        conditions = described_class.new(Article).tableize_conditions(original_conditions)
        expect(conditions).to eq(users: { id: 1 },
                                 mentioned_articles_users: { id: 2 },
                                 mentioned_users_articles: { name: 'a name' },
                                 users_articles: { name: 'deep' },
                                 mentioned_users_articles_2: { name: 'd2' })
      end

      it 'converts complex nested sets with duplicates' do
        original_conditions = { sender: { id: 'sender', articles: { id: 'article1' } },
                                receiver: { id: 'receiver', articles: { id: 'article2' } } }

        conditions = described_class.new(Transaction).tableize_conditions(original_conditions)
        expect(conditions).to eq(users: { id: 'sender' },
                                 articles: { id: 'article1' },
                                 receivers_transactions: { id: 'receiver' },
                                 articles_users: { id: 'article2' })
      end
    end
  end
end
