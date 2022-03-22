# Accessing request data

What if you need to modify the permissions based on something outside of the User object? For example, let's say you want to forbid certain IP addresses from creating comments. The IP address is accessible through request.remote_ip but the Ability class does not have access to this. It's easy to modify what you pass to the Ability object by overriding the current_ability method in ApplicationController.

```ruby
class ApplicationController < ActionController::Base
  #...

  private

  def current_ability
    @current_ability ||= Ability.new(current_user, request.remote_ip)
  end
end
```

```ruby
class Ability
  include CanCan::Ability

  def initialize(user, ip_address=nil)
    can :create, Comment unless DENYLIST_IPS.include? ip_address
  end
end
```

This concept can apply to session and cookies as well.
