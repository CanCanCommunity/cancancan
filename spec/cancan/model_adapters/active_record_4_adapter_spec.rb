require "spec_helper"

if defined? CanCan::ModelAdapters::ActiveRecord4Adapter
  describe CanCan::ModelAdapters::ActiveRecord4Adapter do
    context 'with sqlite3' do
      before :each do
        ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")
        ActiveRecord::Migration.verbose = false
        ActiveRecord::Schema.define do
          create_table(:parents) do |t|
            t.timestamps :null => false
          end

          create_table(:children) do |t|
            t.timestamps :null => false
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

    if Gem::Specification.find_all_by_name('pg').any?
      context 'with postgresql' do
        before :each do
          ActiveRecord::Base.establish_connection(:adapter => "postgresql", :database => "postgres", :schema_search_path => 'public')
          ActiveRecord::Base.connection.drop_database('cancan_postgresql_spec')
          ActiveRecord::Base.connection.create_database 'cancan_postgresql_spec', 'encoding' => 'utf-8', 'adapter' => 'postgresql'
          ActiveRecord::Base.establish_connection(:adapter => "postgresql", :database => "cancan_postgresql_spec")
          ActiveRecord::Migration.verbose = false
          ActiveRecord::Schema.define do
            create_table(:parents) do |t|
              t.timestamps :null => false
            end

            create_table(:children) do |t|
              t.timestamps :null => false
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

        it "allows overlapping conditions in SQL and merge with hash conditions" do
          @ability.can :read, Parent, :children => {:parent_id => 1}
          @ability.can :read, Parent, :children => {:parent_id => 1}

          parent = Parent.create!
          child1 = Child.create!(:parent => parent, :created_at => 1.hours.ago)
          child2 = Child.create!(:parent => parent, :created_at => 2.hours.ago)

          expect(Parent.accessible_by(@ability)).to eq([parent])
        end
      end
    end
  end
end
