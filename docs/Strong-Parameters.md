CanCanCan supports Strong Parameters without controller workarounds. 
When using strong_parameters or Rails 4+, you have to sanitize inputs before saving the record, in actions such as `:create` and `:update`.

By default, CanCanCan will try to sanitize the input on `:create` and `:update` routes by seeing if your controller will respond to the following methods (in order):

### By Action

If you specify a `create_params` or `update_params` method, CanCan will run that method depending on the action you are performing.

```ruby
class ArticlesController < ApplicationController
  load_and_authorize_resource

  def create
    if @article.save
      # hurray
    else
      render :new
    end
  end

  def update
    if @article.update_attributes(update_params)
      # hurray
    else
      render :edit
    end
  end

  private

  def create_params
    params.require(:article).permit(:name, :email)
  end

  def update_params
    params.require(:article).permit(:name)
  end
end
```

### By Model Name

If you follow the convention in rails for naming your param method after the applicable model's class `<model_name>_params` such as `article_params`, CanCanCan will automatically detect and run that params method.

```ruby
class ArticlesController < ApplicationController
  load_and_authorize_resource

  def create
    if @article.save
      # hurray
    else
      render :new
    end
  end

  private

  def article_params
    params.require(:article).permit(:name)
  end
end
```

#### When Model and Controller names differ

When you specify `class` option note that the method will still be `articles_params` and not `post_params`, since we are in `ArticlesController`.

```ruby
class ArticlesController < ApplicationController
  load_and_authorize_resource class: 'Post'

  def create
    if @article.save
      # hurray
    else
      render :new
    end
  end

  private

  def article_params
    params.require(:article).permit(:name)
  end
end
```

### By Static Method Name

CanCanCan also recognizes a static method name: `resource_params`, as a general param method name you can use to standardize on.

```ruby
class ArticlesController < ApplicationController
  load_and_authorize_resource

  def create
    if @article.save
      # hurray
    else
      render :new
    end
  end

  private

  def resource_params
    params.require(:article).permit(:name)
  end
end
```

### By Custom Method

Additionally, load_and_authorize_resource can now take a `param_method` option to specify a custom method in the controller to run to sanitize input.

```ruby
class ArticlesController < ApplicationController
  load_and_authorize_resource param_method: :my_sanitizer

  def create
    if @article.save
      # hurray
    else
      render :new
    end
  end

  private

  def my_sanitizer
    params.require(:article).permit(:name)
  end
end
```

### No Strong Parameters

No problem, if your controllers do not respond to any of the above methods, it will ignore and continue execution as normal.