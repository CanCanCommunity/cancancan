# frozen_string_literal: true

require 'spec_helper'

# integration tests for latest ActiveRecord version.
RSpec.describe CanCan::ModelAdapters::ActiveRecord5Adapter do
  let(:ability) { double.extend(CanCan::Ability) }
  before :each do
    connect_db
    ActiveRecord::Migration.verbose = false

    ActiveRecord::Schema.define do
      create_table(:divisions) do |t|
      end
      
      create_table(:departments) do |t|
        t.string :name
        t.integer :division_id
      end

      create_table(:employees) do |t|
        t.integer :department_id
      end
    end
    
    class Division < ActiveRecord::Base
    end

    class Department < ActiveRecord::Base
      belongs_to :division
      has_many :employees
    end

    class Employee < ActiveRecord::Base
      belongs_to :department
    end
  end

  before do
    @division1 = Division.create!
    @division2 = Division.create!
    @department1 = Department.create!(division: @division1)
    @department2 = Department.create!(division: @division2, name: "People")
    @department3 = Department.create!(division: @division2)
    @user1 = Employee.create!(department: @department1)
    @user2 = Employee.create!(department: @department2)
    @user3 = Employee.create!(department: @department3)
  end

  it "selects the correct objects through the association" do
    ability.can :message, Employee, { department: { id: @department1.id } }
    ability.can :message, Employee, { department: { id: @department2.id } }

    departments = Department.accessible_through(ability, :message, Employee)

    expect(departments.pluck(:id)).to match_array [@department1.id, @department2.id]
  end

  it "treats no condition unconditional" do
    ability.can :message, Employee, { department: { id: @department1.id } }
    ability.can :message, Employee

    # Finds all departments that ability can message employees from
    departments = Department.accessible_through(ability, :message, Employee)

    expect(departments.pluck(:id)).to match_array [@department1.id, @department2.id, @department3.id]
  end

  it "unallowing yields impossible condition" do
    ability.can :message, Employee, { department: { id: @department1.id } }
    ability.cannot :message, Employee

    # Finds all departments that ability can message employees from
    departments = Department.accessible_through(ability, :message, Employee)

    expect(departments.pluck(:id)).to be_empty
  end

  describe 'preloading of associatons' do
    it 'preloads associations correctly' do
      ability.can :message, Employee, { department: { division: { id: @department1.id } } }
  
      department = Department.accessible_through(ability, :message, Employee)
                             .includes(:division).first

      expect(department).to eql @department1
      expect(department.association(:division)).to be_loaded
    end
  end

  describe 'filtering of results' do
    it 'adds the where clause correctly' do
      ability.can :message, Employee, { department: { division: { id: [@department1.id, @department2.id] } } }
  
      department = Department.accessible_through(ability, :message, Employee)
                             .where("name LIKE 'Peo%'").first

      expect(department).to eql @department2
    end
  end

  if CanCan::ModelAdapters::ActiveRecordAdapter.version_greater_or_equal?('5.0.0')
    describe 'selecting custom columns' do
      it 'extracts custom columns correctly' do
        ability.can :message, Employee, { department: { division: { id: @department2.id } } }
    
        department = Department.accessible_through(ability, :message, Employee)
                               .select('name as title').first
  
        expect(department.title).to eql @department2.name
      end
    end
  end
end
