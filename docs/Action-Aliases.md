You will usually be working with four actions when [[defining|Defining Abilities]] and [[checking|Checking Abilities]] permissions: `:read`, `:create`, `:update`, `:destroy`. These aren't the same as the 7 RESTful actions in Rails. CanCanCan automatically adds some convenient aliases for mapping the controller actions.

```ruby
alias_action :index, :show, :to => :read
alias_action :new, :to => :create
alias_action :edit, :to => :update
```

Notice the `edit` action is aliased to `update`. This means if the user is able to update a record he also has permission to edit it. You can define your own aliases in the `Ability` class.

```ruby
class Ability
  include CanCan::Ability
  def initialize(user)
    alias_action :update, :destroy, :to => :modify
    can :modify, Comment
  end
end

# in controller or view
can? :update, Comment # => true
```

You are not restricted to just the 7 RESTful actions, you can use any action name. See [[Custom Actions]] for details.

Please note that if you are changing the default alias_actions, the original actions associated with the alias will NOT be removed.  For example, following statement will not have any effect on the alias :read, which points to :show and :index:

```ruby
alias_action :show, :to => :read # this will have no effect on the alias :read!
```

If you want to change the default actions, you should use clear_aliased_actions method to remove ALL default aliases first.