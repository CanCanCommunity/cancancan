You can bypass CanCanCan's authorization for Devise controllers:

```ruby
class ApplicationController < ActionController::Base
  protect_from_forgery
  check_authorization unless: :devise_controller?
end
```

It may be a good idea to specify the rescue from action:

```ruby
rescue_from CanCan::Unauthorized do |exception|
  if current_user.nil?
    session[:next] = request.fullpath
    redirect_to login_url, alert: 'You have to log in to continue.'
  else
    # render file: "#{Rails.root}/public/403.html", status: 403
    redirect_back(fallback_location: root_path)
  end
end
```