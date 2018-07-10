require 'spec_helper'

if ActiveRecord::VERSION::MAJOR == 5
  describe CanCan::ModelAdapters::ActiveRecord5Adapter do
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

      it 'allows filters on enums' do
        ActiveRecord::Schema.define do
          create_table(:shapes) do |t|
            t.integer :color, default: 0, null: false
          end
        end

        class Shape < ActiveRecord::Base
          unless defined_enums.keys.include? 'color'
            enum color: %i[red green blue]
          end
        end

        red = Shape.create!(color: :red)
        green = Shape.create!(color: :green)
        blue = Shape.create!(color: :blue)

        # A condition with a single value.
        @ability.can :read, Shape, color: :green

        expect(@ability.cannot?(:read, red)).to be true
        expect(@ability.can?(:read, green)).to be true
        expect(@ability.cannot?(:read, blue)).to be true

        accessible = Shape.accessible_by(@ability)
        expect(accessible).to contain_exactly(green)

        # A condition with multiple values.
        @ability.can :update, Shape, color: %i[red blue]

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
          enum color: %i[red green blue] unless defined_enums.keys.include? 'color'
          enum shape: { triangle: 3, rectangle: 4 } unless defined_enums.keys.include? 'shape'
        end

        red_triangle = Disc.create!(color: :red, shape: :triangle)
        green_triangle = Disc.create!(color: :green, shape: :triangle)
        green_rectangle = Disc.create!(color: :green, shape: :rectangle)
        blue_rectangle = Disc.create!(color: :blue, shape: :rectangle)

        # A condition with a dual filter.
        @ability.can :read, Disc, color: :green, shape: :rectangle

        expect(@ability.cannot?(:read, red_triangle)).to be true
        expect(@ability.cannot?(:read, green_triangle)).to be true
        expect(@ability.can?(:read, green_rectangle)).to be true
        expect(@ability.cannot?(:read, blue_rectangle)).to be true

        accessible = Disc.accessible_by(@ability)
        expect(accessible).to contain_exactly(green_rectangle)
      end
    end
  end
end
