** **Attention: Supported only on cancancan < 2.0!** **

CanCanCan supports [[Mongoid|http://mongoid.org]]. All you have to do is mention `mongoid` before `cancan` in your Gemfile so it is required first.

```ruby
gem "mongoid"
gem "cancan"
```

That is it, you can now call `accessible_by` on any Mongoid document (which is done automatically in the `index` action). You can also use the query syntax that Mongoid provides when defining the abilities.

```ruby
# in Ability
can :read, Article, :priority.lt => 5
```

This is all done through a [[Model Adapter]]. See that page for more information and how you can add your own.