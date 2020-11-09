# frozen_string_literal: true

require 'spec_helper'

if CanCan::ModelAdapters::ActiveRecordAdapter.version_lower?('5.0.0')
  describe CanCan::ModelAdapters::ActiveRecord4Adapter do
    # only the `left_join` strategy works in AR4
    CanCan.valid_accessible_by_strategies.each do |strategy|
      context "with sqlite3 and #{strategy} strategy" do
        before :each do
          CanCan.accessible_by_strategy = strategy

          connect_db
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

        if CanCan::ModelAdapters::ActiveRecordAdapter.version_greater_or_equal?('4.1.0')
          it 'allows filters on enums' do
            ActiveRecord::Schema.define do
              create_table(:shapes) do |t|
                t.integer :color, default: 0, null: false
              end
            end

            class Shape < ActiveRecord::Base
              enum color: %i[red green blue] unless defined_enums.key? 'color'
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
              enum color: %i[red green blue] unless defined_enums.key? 'color'
              enum shape: { triangle: 3, rectangle: 4 } unless defined_enums.key? 'shape'
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

      context 'with postgresql' do
        before :each do
          connect_db
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
