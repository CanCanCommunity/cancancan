# Devise

You should bypass CanCanCan's authorization for Devise controllers:

```ruby
class ApplicationController < ActionController::Base
  protect_from_forgery

  check_authorization unless: :devise_controller?
end
```

It may be a good idea to specify the rescue from action:

```ruby
rescue_from CanCan::AccessDenied do |exception|
  if current_user.nil?
    session[:next] = request.fullpath
    redirect_to login_url, alert: 'You have to log in to continue.'
  else
    respond_to do |format|
      format.json { render nothing: true, status: :not_found }
      format.html { redirect_to main_app.root_url, alert: exception.message }
      format.js   { render nothing: true, status: :not_found }
    end
  end
end
```
