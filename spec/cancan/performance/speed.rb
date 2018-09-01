require 'spec_helper'

RSpec.describe 'query performance' do
  before :each do
    ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
    ActiveRecord::Migration.verbose = false
    ActiveRecord::Schema.define do
      create_table(:users) do |t|
        t.string :name
        t.timestamps null: false
      end

      create_table(:proposals) do |t|
        t.string :name
        t.boolean :private
        t.boolean :area_private
        t.boolean :visible_outside
        t.references :user
        t.timestamps null: false
      end

      create_table(:group) do |t|
        t.string :name
        t.references :user
        t.timestamps null: false
      end

      create_table(:group_proposals) do |t|
        t.references :proposal
        t.references :group
        t.timestamps null: false
      end
    end

    class Proposal < ActiveRecord::Base
      has_many :group_proposals
      has_many :groups, through: :group_proposals
    end

    class Group < ActiveRecord::Base
      has_many :group_proposals
      has_many :proposals, through: :group_proposals
    end

    class GroupProposal < ActiveRecord::Base
      belongs_to :proposal
      belongs_to :group
    end

    class User < ActiveRecord::Base
      has_many :proposals
      has_many :groups
    end

    (@ability = double).extend(CanCan::Ability)
  end

  describe '#accessible_by' do
    it 'has different performance using different techniques' do
      report = Benchmark.ips do |x|
        x.report('easy') do
          Proposal.accessible_by(@ability)
        end

        x.compare!
      end
    end
  end
end
