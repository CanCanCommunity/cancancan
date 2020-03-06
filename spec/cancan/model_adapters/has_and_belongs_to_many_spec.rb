require 'spec_helper'

RSpec.describe CanCan::ModelAdapters::ActiveRecord5Adapter do
  let(:ability) { double.extend(CanCan::Ability) }
  let(:users_table) { User.table_name }
  let(:posts_table) { Post.table_name }

  before :all do
    connect_db
    ActiveRecord::Migration.verbose = false

    ActiveRecord::Schema.define do
      create_table(:people) do |t|
        t.string :name
        t.timestamps null: false
      end

      create_table(:houses) do |t|
        t.boolean :restructured, default: true
        t.timestamps null: false
      end

      create_table(:houses_people) do |t|
        t.integer :person_id
        t.integer :house_id
        t.timestamps null: false
      end
    end

    class Person < ActiveRecord::Base
      has_and_belongs_to_many :houses
    end

    class House < ActiveRecord::Base
      has_and_belongs_to_many :people
    end
  end

  before do
    @person1 = Person.create!
    @person2 = Person.create!
    @house1 = House.create!(people: [@person1])
    @house2 = House.create!(restructured: false, people: [@person1, @person2])
    @house3 = House.create!(people: [@person2])
    ability.can :read, House, people: { id: @person1.id }
  end

  describe 'fetching of records' do
    it 'it retreives the records correctly' do
      houses = House.accessible_by(ability)
      expect(houses).to match_array [@house2, @house1]
    end

    if CanCan::ModelAdapters::ActiveRecordAdapter.version_greater_or_equal?('5.0.0')
      it 'generates the correct query' do
        expect(ability.model_adapter(House, :read))
          .to generate_sql("SELECT DISTINCT \"houses\".*
                          FROM \"houses\"
                          LEFT OUTER JOIN \"houses_people\" ON \"houses_people\".\"house_id\" = \"houses\".\"id\"
                          LEFT OUTER JOIN \"people\" ON \"people\".\"id\" = \"houses_people\".\"person_id\"
                          WHERE \"people\".\"id\" = #{@person1.id}")
      end
    end
  end
end
