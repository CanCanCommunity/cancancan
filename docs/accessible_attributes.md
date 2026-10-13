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

## Checks without an attribute

A `can` rule with attributes also allows the action on the object itself, and its conditions are used by `accessible_by`:

```ruby
can :read, User, [:username]

can? :read, @user, :username # => true
can? :read, @user            # => true
User.accessible_by(current_ability) # => all the users
```

`can?` without an attribute answers the question "can the user perform the action on the object, or on some of its attributes?". This is what lets `authorize! :update, @user` pass with `can :update, User, [:name, :email], id: user.id`.
If some attributes must be readable without the object being readable, define them with a separate action, for example `can :read_public_profile, User, [:username]`.

A `cannot` rule with attributes, instead, only forbids the listed attributes:

```ruby
can :update, User
cannot :update, User, [:role]

can? :update, @user        # => true
can? :update, @user, :role # => false
```

To know if there is any attribute left that the user can update, use `current_ability.permitted_attributes(:update, @user).any?`.

## Conditions and submitted values

Conditions are checked against the record as it is stored, not against the values submitted in the request. A rule like `can :update, User, id: user.id, role: "member"` does not prevent a user from changing their own role: use attribute rules and Strong Parameters instead.

```ruby
can :update, User, [:email, :password], id: user.id
```

```ruby
params.require(:user).permit(current_ability.permitted_attributes(:update, @user))
```

## Loading records

Attribute rules are not applied when loading records: `accessible_by` and `load_resource` return records with all their attributes.
Use `permitted_attributes` when rendering them:

```ruby
render json: @books.map { |book| book.slice(*current_ability.permitted_attributes(:read, book)) }
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
