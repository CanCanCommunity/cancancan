# Rules compressions

Database are great on optimizing queries, but sometimes cancancan builds `joins` that might lead to slow performance.
This is why your rules are optimized automatically at runtime.
There are a set of "rules" to optimize your rules definition and they are implemented in the `RulesCompressor` class.
You can always disable the rules compressor by setting `CanCan.rules_compressor_enabled = false` in your initializer.
You can also enable/disable it on a specific check by using: `with_rules_compressor_enabled(false) { ... }`

Here you can see how this works:

A rule without conditions is defined as `catch_all`.

## A catch_all rule, eliminates all previous rules and all subsequent rules of the same type

```ruby
can :read, Book, author_id: user.id
cannot :read, Book, private: true
can :read, Book
can :read, Book, id: 1
cannot :read, Book, private: true
```

becomes

```ruby
can :read, Book
cannot :read, Book, private: true
```

### If a catch_all cannot rule is first, it can be removed

```ruby
cannot :read, Book
can :read, Book, author_id: user.id
```

becomes

```ruby
can :read, Book, author_id: user.id
```

### If all rules are cannot rules, this is equivalent to no rules

```ruby
cannot :read, Book, private: true
```

becomes

```ruby
# nothing
```

These optimizations allow you to follow the strategy of ["Give Permissions, don't take them"](https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities%3A-Best-Practices#give-permissions-dont-take-them-away) and automatically ignore previous rules when they are not needed.
