# Controller helpers

As mentioned in the chapter [Define and check abilities](./define_and_check_abilities.md), the `can?` method works at its bets in Rails controllers and views.
This of course doesn't mean that it cannot be used everywhere.

We know already that in order to check if the user is allowed to perform a certain action we need to have a `current_user` method available and we can check the permission with `can? :update, @article`.

We can easily protect the `edit` and `update` actions of our controller by checking for the permission. Here is a very simple example:

```ruby
class ArticlesController < ApplicationController
  def edit
    @article = Article.find(params[:id])
    if can? :edit, @article
      render :edit
    else
      head :forbidden
    end
  end
end
```

## authorize!

CanCanCan provides us a `authorize!` helper that allows us to simplify the code above:

```ruby
def edit
  @article = Article.find(params[:id])
  authorize! :edit, @article
  render :edit
end
```

`authorize!` will raise a `CanCan::AccessDenied` if the action is not permitted.

You can have a global configuration on how to react to this exception in `config/application.rb`:

```ruby
config.action_dispatch.rescue_responses.merge!('CanCan::AccessDenied' => :unauthorized)
```

The [Handling CanCan::AccessDenied Exception](./handling_exception.md) chapter digs deeper on how to handle the exception raised by `authorize!`.

> `:unauthorized` might not be your favourite return status of you don't want to reveal to the user that the article exists. In such cases `:not_found` would be a better http status. 

# authorize_resource, load_resource, load_and_authorize_resource

In a RESTful controller, calling `authorize! action` for every action can be tedious. Here we will show you, step by step, how to improve the code above.

Add `authorize_resource` in your controller, to call automatically `authorize! action_name, @article` for every action.
The code above can be refactored like this:

```ruby
class ArticlesController < ApplicationController
  before_action :load_article
  authorize_resource

  def edit;  end

  protected

  def load_article
    @article = Article.find(params[:id])
  end
end
```

the second helper method is `load_resource` that will perform the loading of the model automatically based on the name of the controller. The code above can be refactored like that:

```ruby
class ArticlesController < ApplicationController
  load_resource
  authorize_resource

  def edit;  end
end
```

and, clearly, `load_and_authorize_resource` allows to do the following:

```ruby
class ArticlesController < ApplicationController
  load_and_authorize_resource

  def edit;  end
end
```

this means that a completely authorized  `ArticlesController` would look as follow:

```ruby
class ArticlesController < ApplicationController
  load_and_authorize_resource

  def index
    # @articles are already loaded...see details in later chapter
  end

  def show
    # the @article to show is already loaded and authorized
  end

  def create
    # the @article to create is already loaded, authorized, and params set from article_params
    @article.create
  end

  def edit
    # the @article to edit is already loaded and authorized    
  end

  def update
    # the @article to update is already loaded and authorized
    @article.update(article_params)
  end

  def destroy
    # the @article to destroy is already loaded and authorized
    @article.destroy
  end

  protected

  def article_params
    params.require(:article).permit(:body)
  end
end
```

## Strong parameters

You have to sanitize inputs before saving the record, in actions such as `:create` and `:update`.

For the `:update` action, CanCanCan will load and authorize the resource but **not** change it automatically, so the typical usage would be something like:

```ruby
def update
  if @article.update(article_params)
    # hurray
  else
    render :edit
  end
end
...

def article_params
  params.require(:article).permit(:body)
end
```

For the `:create` action, CanCanCan will try to initialize a new instance with sanitized input by seeing if your controller will respond to the following methods (in order):

1. `create_params`
2. `<model_name>_params` such as `article_params` (this is the default convention in Rails for naming your param method)
3. `resource_params` (a generic named method you could specify in each controller)

The typical usage will then be the following:

```ruby
def create
  if @article.save
    # hurray
  else
    render :new
  end
end
```

> If you specify a `create_params` or `update_params` method, CanCan will run that method depending on the action you are performing.

In the chapter dedicated to [Customize controller helpers](./changing_defaults.md) we will see more details and customizations for controllers.

There's a dedicated chapter to [Nested resources](./nested_resources.md).

Now that we know how Rails controllers should be protected, we can learn about the most powerful CanCanCan feature: [fetching records](./fetching_records.md).
