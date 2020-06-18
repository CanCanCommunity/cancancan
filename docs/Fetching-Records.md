Sometimes you need to restrict which records are returned from the database based on what the user is able to access. This can be done with the `accessible_by` method on any Active Record model. Simply pass the current ability to find only the records which the user is able to `:index`.

```ruby
# current_ability is a method made available by CanCanCan in your controllers
@articles = Article.accessible_by(current_ability)
```

You can change the action by passing it as the second argument. Here we find only the records the user has permission to update.

```ruby
@articles = Article.accessible_by(current_ability, :update) 
```

If you want to use the current controller's action, make sure to call `to_sym` on it:

```ruby
@articles = Article.accessible_by(current_ability, params[:action].to_sym)
```

This is an Active Record scope so other scopes and pagination can be chained onto it.

This works with multiple `can` definitions, which allows you to define complex permission logic and have it translated properly to SQL.

Given the definition:
```ruby
class Ability
  can :manage, User, manager_id: user.id
  cannot :manage, User, self_managed: true
  can :manage, User, id: user.id
end
```
a call to User.accessible_by(current_ability) generates the following SQL

```sql
SELECT *
FROM users
WHERE (id = 1) OR (not (self_managed = 't') AND (manager_id = 1))
```

It will raise an exception if any requested model's ability definition is defined using just block. 
You can define SQL fragment in addition to block (look for more examples in [[Defining Abilities with Blocks]]).

If you are using something other than Active Record you can fetch the conditions hash directly from the current ability.

```ruby
current_ability.model_adapter(TargetClass, :read).conditions
```