If your conditions are too complex to define in a hash (as shown in [[Defining Abilities]] page), you can use a block to define them in Ruby.

```ruby
can :update, Project do |project|
  project.priority < 3
end
```

If the block returns true then the user has that ability, otherwise he will be denied access.

## Only for Object Attributes

The block is **only** evaluated when an actual instance object is present. It is not evaluated when checking permissions on the class (such as in the `index` action). This means any conditions which are not dependent on the object attributes should be moved outside of the block.

```ruby
# don't do this
can :update, Project do |project|
  user.admin? # this won't be called for Project.accessible_by(current_ability, :update)
end

# do this
can :update, Project if user.admin?
```
Note that if you pass a block to a `can` or `cannot`, regardless of whether the block asks for parameters (ex. `|project|`) the block only executes if an instance of a class is passed to `can?` or `cannot?`. 

If you define a `can` or `cannot` with a block and an object is not passed, the check will pass. 
```ruby
can :update, Project do |project|
  false
end
```
```ruby
can? :update, Project # returns true!
```

See [[Checking Abilities]] for more information.

## Fetching Records

A block's conditions are only executable through Ruby. If you are [[Fetching Records]] using `accessible_by` it will raise an exception. To fetch records from the database you need to supply an SQL string representing the condition. The SQL will go in the `WHERE` clause, if you need to do joins consider using sub-queries or scopes (below).

```ruby
can :update, Project, ["priority < ?", 3] do |project|
  project.priority < 3
end
```

If you are using `load_resource` and don't supply this SQL argument, the instance variable will not be set for the `index` action since they cannot be translated to a database query.


## Block Conditions with Scopes

It's also possible to pass a scope instead of an SQL string when using a block in an ability.

```ruby
can :read, Article, Article.published do |article|
  article.published_at <= Time.now
end
```

Generally, this breaks down to looks something like:

```ruby
can [:ability], Model, Model.scope_to_select_on_index_action do |model_instance|
  model_instance.condition_to_evaluate_for_new_create_edit_update_destroy
end
```

This is really useful if you have complex conditions which require `joins`. A couple of caveats:

* You cannot use this with multiple `can` definitions that match the same action and model since it is not possible to combine them. An exception will be raised when that is the case.
* If you use this with `cannot`, the scope needs to be the inverse since it's passed directly through. For example, if you don't want someone to read discontinued products the scope will need to fetch non discontinued ones:

```ruby
cannot :read, Product, Product.where(:discontinued => false) do |product|
  product.discontinued?
end
```

It is only recommended to use scopes if a situation is too complex for a hash condition.

## Overriding All Behavior

You can override all `can` behaviour by passing no arguments, this is useful when permissions are defined outside of ruby such as when defining [[Abilities in Database]].

```ruby
can do |action, subject_class, subject|
  # ...
end
```

Here the block will be triggered for every `can?` check, even when only a class is used in the check.


## Additional Docs

* [[Defining Abilities]]
* [[Checking Abilities]]
* [[Testing Abilities]]
* [[Debugging Abilities]]
* [[Ability Precedence]]
