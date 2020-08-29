The default operation for CanCanCan is to authorize based on user and the object identified in `load_resource`.  So if you have a `WidgetsController` and also an `Admin::WidgetsController`, you can use some different approaches.

Just like in the example given for [[Accessing Request Data]], you **can** also create differing authorization rules that depend on the controller namespace.  

In this case, just override the `current_ability` method in `ApplicationController` to include the controller namespace, and create an `Ability` class that knows what to do with it.

``` ruby
class Admin::WidgetsController < ActionController::Base
  #...

  private

  def current_ability
    # I am sure there is a slicker way to capture the controller namespace
    controller_name_segments = params[:controller].split('/')
    controller_name_segments.pop
    controller_namespace = controller_name_segments.join('/').camelize
    @current_ability ||= Ability.new(current_user, controller_namespace)
  end
end


class Ability
  include CanCan::Ability

  def initialize(user, controller_namespace)
    case controller_namespace
      when 'Admin'
        can :manage, :all if user.has_role? 'admin'
      else
        # rules for non-admin controllers here
    end
  end
end
```

Another way to achieve the same is to use a completely different Ability class in this controller:

``` ruby
class Admin::WidgetsController < ActionController::Base
  #...

  private

  def current_ability
    @current_ability ||= AdminAbility.new(current_user)
  end
end
```

and follow the [Best Practice of splitting your Ability file into multiple files](https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities%3A-Best-Practices#split-your-abilityrb-file).