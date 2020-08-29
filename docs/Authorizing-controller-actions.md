You can use the `authorize!` method to manually handle authorization in a controller action. This will raise a `CanCan::AccessDenied` exception when the user does not have permission. See [[Exception Handling]] for how to react to this.

```ruby
def show
  @project = Project.find(params[:project])
  authorize! :show, @project
end
```

However that can be tedious to apply to each action. Instead you can use the `load_and_authorize_resource` method in your controller to load the resource into an instance variable and authorize it automatically for every action in that controller.

```ruby
class ProductsController < ActionController::Base
  load_and_authorize_resource
end
```

This is the same as calling `load_resource` and `authorize_resource` because they are two separate steps and you can choose to use one or the other.

```ruby
class ProductsController < ActionController::Base
  load_resource
  authorize_resource
end
```

As of CanCan 1.5 you can use the `skip_load_and_authorize_resource`, `skip_load_resource` or `skip_authorize_resource` methods to skip any of the applied behavior and specify specific actions like in a before filter. For example.

```ruby
class ProductsController < ActionController::Base
  load_and_authorize_resource
  skip_authorize_resource :only => :new
end
```

**important notice about `:manage` rules**

Using `load_and_authorize_resource` with a rule like `can :manage, Article, id: 23` will allow rendering the `new` method of the ArticlesController, which is unexpected because this rule naively reads as _"the user can manage the existing article with id 23"_, which should have nothing to do with creating new articles.

But in reality the rule means _"the user can manage any article object with an id field set to 23"_, which includes creating a new Article with the id set to 23 like `Article.new(id: 23)`.

Thus `load_and_authorize_resource` will initialize a model in the `:new` action and set its id to 23, and happily render the page. Saving will not work though.

The correct intended rule to avoid `new` being allowed would be:

``` ruby
can [:read, :update, :destroy], Article, id: 23
```

Also see [[Controller Authorization Example]], [[Ensure Authorization]] and [[Non RESTful Controllers]].


## Choosing Actions

By default this will apply to **every action** in the controller even if it is not one of the 7 RESTful actions. The action name will be passed in when authorizing. For example, if we have a `discontinue` action on `ProductsController` it will have this behavior.

```ruby
class ProductsController < ActionController::Base
  load_and_authorize_resource
  def discontinue
    # Automatically does the following:
    # @product = Product.find(params[:id])
    # authorize! :discontinue, @product
  end
end
```

You can specify which actions to affect using the `:except` and `:only` options, just like a `before_action`.

```ruby
load_and_authorize_resource :only => [:index, :show]
```
### Choosing actions on nested resources 

For this you can pass a name to skip_authorize_resource.
For example:
```ruby
class CommentsController < ApplicationController
  load_and_authorize_resource :post
  load_and_authorize_resource :through => :post

  skip_authorize_resource :only => :show  
  skip_authorize_resource :post, :only => :show
end
```

The first skip_authorize_resource skips authorization check for comment and the second for post. Both are needed if you want to skip all authorization checks for an action.

## load_resource

### index action

As of 1.4 the index action will load the collection resource using `accessible_by`.

```ruby
def index
  # @products automatically set to Product.accessible_by(current_ability)
end
```

If you want custom find options such as [[includes|https://github.com/ryanb/cancan/issues#issue/259]] or pagination, you can build on this further since it is a scope.

```ruby
def index
  @products = @products.includes(:category).page(params[:page])
end
```

The `@products` variable will not be set initially if `Product` does not respond to `accessible_by` (such as if you aren't using a supported ORM). It will also not be set if you are only using a block in the `can` definitions because there is no way to determine which records to fetch from the database.

### show, edit, update and destroy actions

These member actions simply fetch the record directly.

```ruby
def show
  # @product automatically set to Product.find(params[:id])
end
```

### new and create actions

As of 1.4 these builder actions will initialize the resource with the attributes in the hash conditions. For example, if we have this `can` definition.

```ruby
can :manage, Product, :discontinued => false
```

Then the product will be built with that attribute in the controller.

```ruby
@product = Product.new(:discontinued => false)
```

This way it will pass authorization when the user accesses the `new` action.

The attributes are then overridden by whatever is passed by the user in `params[:product]`.

### Custom class

If the model is named differently than the controller, then you may explicitly name the model that should be loaded; however, you must specify that it is not a parent in a nested routing situation, ie:

```ruby
class ArticlesController < ApplicationController
  load_and_authorize_resource :post, :parent => false
end
```

If the model class is namespaced differently than the controller you will need to specify the `:class` option.

```ruby
class ProductsController < ApplicationController
  load_and_authorize_resource :class => "Store::Product"
end
```


### Custom find

If you want to fetch a resource by something other than `id` it can be done so using the `find_by` option.

```ruby
load_resource :find_by => :permalink # will use find_by_permalink!(params[:id])
authorize_resource
```

### Override loading

The resource will only be loaded into an instance variable if it hasn't been already. This allows you to easily override how the loading happens in a separate `before_action`.

```ruby
class BooksController < ApplicationController
  before_action :find_published_book, :only => :show
  load_and_authorize_resource

  private

  def find_published_book
    @book = Book.released.find(params[:id])
  end
end
```

It is important that any custom loading behavior happens **before** the call to `load_and_authorize_resource`. If you have `authorize_resource` in your `ApplicationController` then you need to use `prepend_before_action` to do the loading in the controller subclasses so it happens before authorization.

## authorize_resource

Adding `authorize_resource` will install a `before_action` callback that calls `authorize!`, passing the resource instance variable if it exists. If the instance variable isn't set (such as in the index action) it will pass in the class name. For example, if we have a `ProductsController` it will do this before each action.

```ruby
authorize!(params[:action].to_sym, @product || Product)
```

## More info

For additional information see the `load_resource` and `authorize_resource` methods in the [[RDoc|http://www.rubydoc.info/github/CanCanCommunity/cancancan]].

Also see [[Nested Resources]] and [[Non RESTful Controllers]].

## Resetting Current Ability

If you ever update a User record which may be the current user, it will make the current ability for that request stale. This means any `can?` checks will use the user record before it was updated. You will need to reset the `current_ability` instance so it will be reloaded. Do the same for the `current_user` if you are caching that too.

```ruby
if @user.update_attributes(params[:user])
  @current_ability = nil
  @current_user = nil
  # ...
end
```