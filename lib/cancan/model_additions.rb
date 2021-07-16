# frozen_string_literal: true

module CanCan
  # This module adds the accessible_by class method to a model. It is included in the model adapters.
  module ModelAdditions
    module ClassMethods
      # Returns a scope which fetches only the records that the passed ability
      # can perform a given action on. The action defaults to :index. This
      # is usually called from a controller and passed the +current_ability+.
      #
      #   @articles = Article.accessible_by(current_ability)
      #
      # Here only the articles which the user is able to read will be returned.
      # If the user does not have permission to read any articles then an empty
      # result is returned. Since this is a scope it can be combined with any
      # other scopes or pagination.
      #
      # An alternative action can optionally be passed as a second argument.
      #
      #   @articles = Article.accessible_by(current_ability, :update)
      #
      # Here only the articles which the user can update are returned.
      def accessible_by(ability, action = :index, strategy: CanCan.accessible_by_strategy)
        CanCan.with_accessible_by_strategy(strategy) do
          ability.model_adapter(self, action).database_records
        end
      end

      # Provides a scope within the model, to find instances of the model that
      # are accesssible by the given ability, within the given action/subject
      # permission pair.
      # I.E.:
      #    Given the scenario below
      #
      #      class Department < ActiveRecord::Base
      #      end
      #
      #      class User < ActiveRecord::Base
      #        belongs_to :department
      #      end
      #
      #      class Ability
      #        include CanCan::Ability
      #
      #        def initialize(user)
      #          can :contact, User, { department: { id: user.department_id } }
      #          can :contact, User, { department: { id: user.managing_department_ids } } if user.manager?
      #        end
      #      end
      #
      #    This would give you a list of territories that the given ability can
      #    contact their users:
      #
      #      > user = User.new(department_id: 13, manager: false)
      #      > ability = Ability.new(user)
      #      > Department.accessible_through(ability, :contact, User).to_sql
      #      => SELECT * FROM territories WHERE id = 13
      #
      #      > user = User.new(department_id: 13, managing_department_ids: [2, 3, 4], manager: true)
      #      > ability = Ability.new(user)
      #      > Department.accessible_through(ability, :contact, User).to_sql
      #      => SELECT * FROM territories WHERE ((id = 13) OR (id IN (2, 3, 4)))
      #
      #    Sometimes the name of the relation does't match the model, when that happens, you can override it with `relation`:
      #
      #      class User < ActiveRecord::Base
      #        has_many :managing_users, class_name: "User", foreign_key: :managed_by_id
      #      end
      #
      #      class Ability
      #        include CanCan::Ability
      #
      #        def initialize(user)
      #          can :contact, User, { managing_users: { id: user.department_id } }
      #        end
      #      end
      #
      #    This would give you a list of territories that the given ability can
      #    contact their users:
      #
      #      > user = User.new(department_id: 13, manager: false)
      #      > ability = Ability.new(user)
      #      > Department.accessible_through(ability, :contact, User).to_sql
      #      => SELECT * FROM territories WHERE id = 13
      #
      #      > user = User.new(department_id: 13, managing_department_ids: [2, 3, 4], manager: true)
      #      > ability = Ability.new(user)
      #      > Department.accessible_through(ability, :contact, User).to_sql
      #      => SELECT * FROM territories WHERE ((id = 13) OR (id IN (2, 3, 4)))
      def accessible_through(ability, action, subject, relation: model_name.element, strategy: CanCan.accessible_by_strategy)
        CanCan.with_accessible_by_strategy(strategy) do
          ability.relation_model_adapter(self, action, subject, relation)
                 .database_records
        end
      end
    end

    def self.included(base)
      base.extend ClassMethods
    end
  end
end
