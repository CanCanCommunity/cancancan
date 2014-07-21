require "spec_helper"

if defined? CanCan::ModelAdapters::ActiveRecord4Adapter
  describe CanCan::ModelAdapters::ActiveRecord4Adapter do
    before :each do
      ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")
      ActiveRecord::Migration.verbose = false
      ActiveRecord::Schema.define do
        create_table(:parents) do |t|
          t.timestamps
        end

        create_table(:children) do |t|
          t.timestamps
          t.integer :parent_id
        end
      end

      class Parent < ActiveRecord::Base
        has_many :children, lambda { order(:id => :desc) }
      end

      class Child < ActiveRecord::Base
        belongs_to :parent
      end

      (@ability = double).extend(CanCan::Ability)
    end

    it "respects scope on included associations" do
      @ability.can :read, [Parent, Child]

      parent = Parent.create!
      child1 = Child.create!(:parent => parent, :created_at => 1.hours.ago)
      child2 = Child.create!(:parent => parent, :created_at => 2.hours.ago)

      expect(Parent.accessible_by(@ability).order(:created_at => :asc).includes(:children).first.children).to eq [child2, child1]
    end
  end
end
