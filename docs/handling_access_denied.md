# Handling CanCan::AccessDenied

In the [Controller helpers](./controller_helpers.md) chapter, we saw that when a resource is not authorized, a `CanCan::AccessDenied` exception is raised, and we offered a basic handling through `config/application.rb`. Let's now see what else we can do.

The `CanCan::AccessDenied` exception is raised when calling `authorize!` in the controller and the user is not able to perform the given action.

A message can optionally be provided.

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
    action_name:
      model_name: "..."
```

Notice `manage` and `all` can be used to generalize the subject and actions. Also `%{action}` and `%{subject}` can be used as interpolated variables in the message.

You can catch the exception and modify its behavior in the `ApplicationController`. The behavior may vary depending on the request format. For example here we set the error message to a flash and redirect to the home page for HTML requests and return `403 Forbidden` for JSON requests.

```ruby
class ApplicationController < ActionController::Base
  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.json { head :forbidden }
      format.html { redirect_to root_path, alert: exception.message }
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
