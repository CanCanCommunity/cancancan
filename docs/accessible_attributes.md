# Accessible attributes

CanCanCan gives you the possibility to define actions on single instances' attributes.

Given you want users to only read a user first name and last name you can define:

```ruby
can :read, User, [:first_name, :last_name]
```

and check it with:

```ruby
can? :read, @user, :first_name
```

You can also ask for all the allowed attributes:

```ruby
current_ability.permitted_attributes(:read, @user)
#=> [:first_name, :last_name]
```

This can be used, for example, to display a form:

```ruby
current_ability.permitted_attributes(:read, @book).each do |attr|
  = form.input attr
```

or in Strong Parameters:

```ruby
params
  .require(:book)
  .permit(current_ability.permitted_attributes(:read, @book))
```

## Disallowed attributes

`disallowed_attributes` is the opposite of `permitted_attributes`: it returns the attributes that a `cannot` rule forbids and no later `can` rule allows again.

```ruby
can :update, Product
cannot :update, Product, [:price]

current_ability.disallowed_attributes(:update, @product)
#=> [:price]
```

It is useful as a deny list when the input contains keys that are not attributes of the model, for example a GraphQL input object with translated fields: `permitted_attributes` would not include them, while `disallowed_attributes` only removes what is explicitly forbidden.

```ruby
attributes.except(*current_ability.disallowed_attributes(:update, @product))
```

An empty result does not mean that the action is allowed: when no rule is defined, nothing is disallowed either. Always authorize the action itself with `authorize!` or `can?`.
