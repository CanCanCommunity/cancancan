require 'spec_helper'

if defined? CanCan::ModelAdapters::ActiveRecord4Adapter
  describe CanCan::ModelAdapters::ActiveRecord4Adapter do
    context 'with sqlite3' do
      before :each do
        ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
        ActiveRecord::Migration.verbose = false
        ActiveRecord::Schema.define do
          create_table(:parents) do |t|
            t.timestamps null: false
          end

          create_table(:children) do |t|
            t.timestamps null: false
            t.integer :parent_id
          end
        end

        class Parent < ActiveRecord::Base
          has_many :children, -> { order(id: :desc) }
        end

        class Child < ActiveRecord::Base
          belongs_to :parent
        end

        (@ability = double).extend(CanCan::Ability)
      end

      it 'respects scope on included associations' do
        @ability.can :read, [Parent, Child]

        parent = Parent.create!
        child1 = Child.create!(parent: parent, created_at: 1.hours.ago)
        child2 = Child.create!(parent: parent, created_at: 2.hours.ago)

        expect(Parent.accessible_by(@ability).order(created_at: :asc).includes(:children).first.children)
          .to eq [child2, child1]
      end

      if ActiveRecord::VERSION::MINOR >= 1
        it 'allows filters on enums' do
          ActiveRecord::Schema.define do
            create_table(:shapes) do |t|
              t.integer :color, default: 0, null: false
            end
          end

          class Shape < ActiveRecord::Base
            enum color: [:red, :green, :blue]
          end

          red = Shape.create!(color: :red)
          green = Shape.create!(color: :green)
          blue = Shape.create!(color: :blue)

          # A condition with a single value.
          @ability.can :read, Shape, color: Shape.colors[:green]

          expect(@ability.cannot?(:read, red)).to be true
          expect(@ability.can?(:read, green)).to be true
          expect(@ability.cannot?(:read, blue)).to be true

          accessible = Shape.accessible_by(@ability)
          expect(accessible).to contain_exactly(green)

          # A condition with multiple values.
          @ability.can :update, Shape, color: [Shape.colors[:red],
                                               Shape.colors[:blue]]

          expect(@ability.can?(:update, red)).to be true
          expect(@ability.cannot?(:update, green)).to be true
          expect(@ability.can?(:update, blue)).to be true

          accessible = Shape.accessible_by(@ability, :update)
          expect(accessible).to contain_exactly(red, blue)
        end

        it 'allows dual filter on enums' do
          ActiveRecord::Schema.define do
            create_table(:discs) do |t|
              t.integer :color, default: 0, null: false
              t.integer :shape, default: 3, null: false
            end
          end

          class Disc < ActiveRecord::Base
            enum color: [:red, :green, :blue]
            enum shape: { triangle: 3, rectangle: 4 }
          end

          red_triangle = Disc.create!(color: Disc.colors[:red], shape: Disc.shapes[:triangle])
          green_triangle = Disc.create!(color: Disc.colors[:green], shape: Disc.shapes[:triangle])
          green_rectangle = Disc.create!(color: Disc.colors[:green], shape: Disc.shapes[:rectangle])
          blue_rectangle = Disc.create!(color: Disc.colors[:blue], shape: Disc.shapes[:rectangle])

          # A condition with a dual filter.
          @ability.can :read, Disc, color: Disc.colors[:green], shape: Disc.shapes[:rectangle]

          expect(@ability.cannot?(:read, red_triangle)).to be true
          expect(@ability.cannot?(:read, green_triangle)).to be true
          expect(@ability.can?(:read, green_rectangle)).to be true
          expect(@ability.cannot?(:read, blue_rectangle)).to be true

          accessible = Disc.accessible_by(@ability)
          expect(accessible).to contain_exactly(green_rectangle)
        end
      end
    end

    if Gem::Specification.find_all_by_name('pg').any?
      context 'with postgresql' do
        before :each do
          ActiveRecord::Base.establish_connection(adapter: 'postgresql',
                                                  database: 'postgres',
                                                  schema_search_path: 'public')
          ActiveRecord::Base.connection.drop_database('cancan_postgresql_spec')
          ActiveRecord::Base.connection.create_database('cancan_postgresql_spec',
                                                        'encoding' => 'utf-8',
                                                        'adapter' => 'postgresql')
          ActiveRecord::Base.establish_connection(adapter: 'postgresql',
                                                  database: 'cancan_postgresql_spec')
          ActiveRecord::Migration.verbose = false
          ActiveRecord::Schema.define do
            create_table(:parents) do |t|
              t.timestamps null: false
            end

            create_table(:children) do |t|
              t.timestamps null: false
              t.integer :parent_id
            end
          end

          class Parent < ActiveRecord::Base
            has_many :children, -> { order(id: :desc) }
          end

          class Child < ActiveRecord::Base
            belongs_to :parent
          end

          (@ability = double).extend(CanCan::Ability)
        end

        it 'allows overlapping conditions in SQL and merge with hash conditions' do
          @ability.can :read, Parent, children: { parent_id: 1 }
          @ability.can :read, Parent, children: { parent_id: 1 }

          parent = Parent.create!
          Child.create!(parent: parent, created_at: 1.hours.ago)
          Child.create!(parent: parent, created_at: 2.hours.ago)

          expect(Parent.accessible_by(@ability)).to eq([parent])
        end
      end
    end
  end
end
