# Define abilities with blocks

If your conditions are too complex to define in a [hash of conditions](./hash_of_conditions.md), you can use a block to define them in Ruby.

```ruby
can :update, Project do |project|
  project.priority < 3
end
```

Note that if you pass a block to a `can` or `cannot`, the block only executes if an instance of a class is passed to `can?` or `cannot?` calls.

If you define a `can` or `cannot` with a block and an object is not passed, the check will pass.

```ruby
can :update, Project do |project|
  false
end
```

```ruby
can? :update, Project # returns true!
```

## Fetching Records

A block's conditions are only executable through Ruby. If you are [Fetching Records](./fetching_records.md) using `accessible_by` it will raise an exception.

To fetch records from the database you need to supply an SQL string representing the condition. The SQL will go in the `WHERE` clause:

```ruby
can :update, Project, ["priority < ?", 3] do |project|
  project.priority < 3
end
```

> If you are using `load_resource` and don't supply this SQL argument, the instance variable will not be set for the `index` action since they cannot be translated to a database query.

## Block Conditions with ActiveRecord Scopes

It's also possible to pass a scope instead of an SQL string when using a block in an ability.

```ruby
can :read, Article, Article.published do |article|
  article.published_at <= Time.now
end
```

This is really useful if you have complex conditions which require `joins`. A couple of caveats:

- You cannot use this with multiple `can` definitions that match the same action and model since it is not possible to combine them. An exception will be raised when that is the case.
- If you use this with `cannot`, the scope needs to be the inverse since it's passed directly through. For example, if you don't want someone to read discontinued products the scope will need to fetch non discontinued ones:

```ruby
cannot :read, Product, Product.where(discontinued: false) do |product|
  product.discontinued?
end
```

It is only recommended to use scopes if a situation is too complex for a hash condition.
