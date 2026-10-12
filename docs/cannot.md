# Cannot

Yes, sometimes you might need to **remove** permissions. Even if we said that CanCanCan assumes that by default no one has access to any resource, there are situations where you might need to remove an ability.

The `cannot` method takes the same arguments as `can` and defines which actions the user is unable to perform. This is normally done after a more generic `can` call.

```ruby
can :manage, Project
cannot :destroy, Project
```

will allow the user to do **any** action but destroy the project.

Of course, there's a `cannot?` method to check abilities that is a simple alias for `!can?`.

## Remove all permissions

`cannot` supports the special subject `:all`.

```ruby
cannot :manage, :all  # user cannot perform any action on any object
```

## Conditions and NULL values

A `cannot` rule with conditions only removes the records that match them. A record whose column is `NULL` does not match, so it stays accessible, both for `can?` and for `accessible_by`:

```ruby
can :read, Article
cannot :read, Article, secret: true

can? :read, Article.new(secret: true)   # => false
can? :read, Article.new(secret: nil)    # => true
Article.accessible_by(ability)          # => the articles where secret is false or NULL
```

## Single table inheritance

Rules can be defined on the subclasses of a model that uses single table inheritance. A `cannot` rule on a subclass removes its records from the queries on the base class as well:

```ruby
can :read, Vehicle
cannot :read, Car

can? :read, Motorbike.first   # => true
can? :read, Car.first         # => false
Vehicle.accessible_by(ability)  # => all the vehicles except the cars
Car.accessible_by(ability)      # => no records
```
