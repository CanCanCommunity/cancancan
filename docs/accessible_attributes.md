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
