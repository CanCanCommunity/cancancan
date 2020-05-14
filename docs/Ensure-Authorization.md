If you want to be certain authorization is not forgotten in some controller action, add `check_authorization` to your `ApplicationController`.

```ruby
class ApplicationController < ActionController::Base
  check_authorization
end
```

This will add an `after_filter` to ensure authorization takes place in every inherited controller action. If no authorization happens it will raise a `CanCan::AuthorizationNotPerformed` exception. You can skip this check by adding `skip_authorization_check` to that controller. Both of these methods take the same arguments as `before_filter` so you can exclude certain actions with `:only` and `:except`.

```ruby
class UsersController < ApplicationController
  skip_authorization_check :only => [:new, :create]
  # ...
end
```

## Conditionally Check Authorization

As of CanCan 1.6, the `check_authorization` method supports `:if` and `:unless` options. Either one takes a method name as a symbol. This method will be called to determine if the authorization check will be performed. This makes it very easy to skip this check on all Devise controllers since they provide a `devise_controller?` method.

```ruby
class ApplicationController < ActionController::Base
  check_authorization :unless => :devise_controller?
end
```

Here's another example where authorization is only ensured for the admin subdomain.

```ruby
class ApplicationController < ActionController::Base
  check_authorization :if => :admin_subdomain?
  private
  def admin_subdomain?
    request.subdomain == "admin"
  end
end
```

Note: The `check_authorization` only ensures that authorization is performed. If you have `authorize_resource` the authorization will still be performed no matter what is returned here.
