CanCanCan makes two assumptions about your application.

* You have an `Ability` class which defines the permissions.
* You have a `current_user` method in the controller which returns the current user model.

You can override both of these by defining the `current_ability` method in your `ApplicationController`. The current method looks like this.

```ruby
def current_ability
  @current_ability ||= Ability.new(current_user)
end
```

The `Ability` class and `current_user` method can easily be changed to something else.

```ruby
# in ApplicationController
def current_ability
  @current_ability ||= AccountAbility.new(current_account)
end
```

Sometimes you might have a gem in your project which provides its own Rails engine which also uses CanCanCan such as LocomotiveCMS. In this case the current_ability override in the ApplicationController can also be useful.

```ruby
# in ApplicationController
def current_ability
  if request.fullpath =~ /\/locomotive/
    @current_ability ||= Locomotive::Ability.new(current_user)
  else
    @current_ability ||= Ability.new(current_user)
  end
end
```

If your method that returns the currently logged in user just has another name than `current_user`, it may be the easiest solution to simply alias the method in your ApplicationController like this:

```ruby
class ApplicationController < ActionController::Base
  alias_method :current_user, :name_of_your_method # Could be :current_member or :logged_in_user
end
```

That's it! See [[Accessing Request Data]] for a more complex example of what you can do here.