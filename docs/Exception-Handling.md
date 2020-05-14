The `CanCan::AccessDenied` exception is raised when calling `authorize!` in the controller and the user is not able to perform the given action. A message can optionally be provided.

```ruby
authorize! :read, Article, :message => "Unable to read this article."
```

This exception can also be raised manually if you want more custom behavior.

```ruby
raise CanCan::AccessDenied.new("Not authorized!", :read, Article)
```

The message can also be customized through internationalization.

```yaml
# in config/locales/en.yml
en:
  unauthorized:
    manage:
      all: "Not authorized to %{action} %{subject}."
      user: "Not allowed to manage other user accounts."
    update:
      project: "Not allowed to update this project."
```

Notice `manage` and `all` can be used to generalize the subject and actions. Also `%{action}` and `%{subject}` can be used as variables in the message.

You can catch the exception and modify its behavior in the `ApplicationController`. The behavior may vary depending on the request format. For example here we set the error message to a flash and redirect to the home page for HTML requests and return `403 Forbidden` for JSON requests.

```ruby
class ApplicationController < ActionController::Base
  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.json { head :forbidden }
      format.html { redirect_to main_app.root_url, :alert => exception.message }
    end
  end
end
```

The action and subject can be retrieved through the exception to customize the behavior further.

```ruby
exception.action # => :read
exception.subject # => Article
```

The default error message can also be customized through the exception. This will be used if no message was provided.

```ruby
exception.default_message = "Default error message"
exception.message # => "Default error message"
```

If you prefer to return the 403 Forbidden HTTP code, create a `public/403.html` file and write a rescue_from statement like this example in `ApplicationController`:

```ruby
class ApplicationController < ActionController::Base
  rescue_from CanCan::AccessDenied do |exception|
    render :file => "#{Rails.root}/public/403.html", :status => 403, :layout => false
    ## to avoid deprecation warnings with Rails 3.2.x (and incidentally using Ruby 1.9.3 hash syntax)
    ## this render call should be:
    # render file: "#{Rails.root}/public/403", formats: [:html], status: 403, layout: false
  end
end 
```

`403.html` must be pure HTML, CSS, and JavaScript--not a template. The fields of the exception are not available to it.

If you are getting unexpected behavior when rescuing from the exception it is best to add some logging . See [[Debugging Abilities]] for details.

## Rescuing exceptions for XML responses

If your web application provides a web service which returns XML or JSON responses then you will likely want to handle Authorization properly with a 403 response. You can do so by rendering a response when rescuing from the exception.

```ruby
rescue_from CanCan::AccessDenied do |exception|
  respond_to do |format|
    format.json { render nothing: true, status: :forbidden }
    format.xml { render xml: '...', status: :forbidden }
    format.html { redirect_to main_app.root_url, alert: exception.message }
  end
end
```

## Danger of exposing sensible information

Please read [this thread](https://github.com/CanCanCommunity/cancancan/issues/437) for more information.

In a Rails application, if a record is not found during `load_and_authorize_resource` it raises `ActiveRecord::NotFound` before it checks _authentication_ in the `authorize` step.

This means that secured routes can have their resources discovered without even being signed in:

```
$ curl -I https://app.example.com/restricted_resource/does-not-exist
HTTP/1.1 404 Not Found

$ curl -I https://app.example.com/restricted_resource/does-exist-but-not-permitted
HTTP/1.1 302 Found
Location: https://app.example.com/sessions/new
```

A more secure approach is to **always** return a 404 status instead of 302:

```ruby
class ApplicationController < ActionController::Base
  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.json { render nothing: true, status: :not_found }
      format.html { redirect_to main_app.root_url, notice: exception.message, status: :not_found }
      format.js   { render nothing: true, status: :not_found }
    end
  end
end
```