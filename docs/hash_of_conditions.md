# Defining abilities - Hash of conditions

Let's start our journey into the abilities definition by explaining the CanCanCan Hash of conditions mechanism.

In the chapter [Define and Check Abilities](./define_check_abilities.md) we defined

```ruby
can :update, @article, user: user
```

to say that an Article can be updated only by it's author. But how does it work?

The third argument of the `can` method (`{ user: user }`) is the hash of conditions for this rule.

A hash of conditions can be passed to further restrict which records this permission applies to.

In the example below the user will only have permission to read active projects which they own.

```ruby
can :read, Project, active: true, user_id: user.id
```

When defining a condition, the key should always be either a database column of the model, or the association name. In the example above, if the Project has defined

```ruby
belongs_to :owner, class_name: 'User', foreign_key: :user_id
```

the rule can also be written as:

```ruby
can :read, Project, active: true, owner: user
```

so by using the association `owner` instead of the database column `user_id`.

You can nest conditions associations. Here the project can only be read if the category it belongs to is visible.

```ruby
can :read, Project, category: { visible: true }
```

An array or range can be passed to match multiple values. Here the user can only read projects of priority 1 through 3.

```ruby
can :read, Project, priority: 1..3
```

If you want to a negative match, you can pass in `nil`.

```ruby
# Can read projects that don't have any members.
can :read, Project, members: { id: nil }
```

Almost anything that you can pass to a hash of conditions in ActiveRecord will work here as well.

## Traverse associations

All associations can be traversed when defining a rule.

```ruby
class User
  belongs_to :account
end

class Account
  has_one :user
  has_many :services
end

class Service
  belongs_to :account
  has_many :parts
end

class Part
  belongs_to :service
end

# Ability
can :manage, Part, service: { account: { user: user } }
```

Let's now quickly see how to [Combine Abilities](./combine_abilities.md)
