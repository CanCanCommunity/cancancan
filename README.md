# CanCanCan

<img src="./logo/cancancan.png" width="200" />

[![Gem Version](https://badge.fury.io/rb/cancancan.svg)](http://badge.fury.io/rb/cancancan)
[![Github Actions badge](https://github.com/CanCanCommunity/cancancan/actions/workflows/test.yml/badge.svg)](https://github.com/CanCanCommunity/cancancan/actions/workflows/test.yml/badge.svg)
[![Code Climate Badge](https://codeclimate.com/github/CanCanCommunity/cancancan.svg)](https://codeclimate.com/github/CanCanCommunity/cancancan)

[Wiki](./docs) |
[RDocs](http://rdoc.info/projects/CanCanCommunity/cancancan) |
[Screencast 1](http://railscasts.com/episodes/192-authorization-with-cancan) |
[Screencast 2](https://www.youtube.com/watch?v=cTYu-OjUgDw)

CanCanCan is an authorization library for Ruby and Ruby on Rails which restricts what
resources a given user is allowed to access.

All permissions can be defined in one or multiple ability files and not duplicated across controllers, views,
and database queries, keeping your permissions logic in one place for easy maintenance and testing.

It consists of two main parts:
1. **Authorizations library** that allows you to define the rules to access different objects,
and provides helpers to check for those permissions.

2. **Rails helpers** to simplify the code in Rails Controllers by performing the loading and checking of permissions
of models automatically and reduce duplicated code.

## Sponsored by

<a href="https://www.renuo.ch" target="_blank">
  <img src="./logo/renuo.png" alt="Renuo AG" width="200"/>
</a>
<br/>
<br/>
<a href="https://www.moderntreasury.com" target="_blank"  style="display:inline">
  <img src="./logo/modern_treasury.svg" alt="Modern Treasury" width="400"/>
</a>
<br/>
<br/>
<a href="https://bullettrain.co" target="_blank">
  <img src="./logo/bullet_train.png" alt="Bullet Train" width="400"/>
</a>
<br/>
<br/>
<a href="https://jobs.goboony.com/fullstack-ruby-on-rails-developer" target="_blank">
  <img src="./logo/goboony.png" alt="Goboony" width="310"/>
</a>
<br />
<br />

Do you want to sponsor CanCanCan and show your logo here?
Check our [Sponsors Page](https://github.com/sponsors/coorasse).

## Installation

Add this to your Gemfile:

    gem 'cancancan'

and run the `bundle install` command.

## Define Abilities

User permissions are defined in an `Ability` class.

    rails g cancan:ability

Here follows an example of rules defined to read a Post model.
```ruby
class Ability
  include CanCan::Ability

  def initialize(user)
    can :read, Post, public: true

    if user.present?  # additional permissions for logged in users (they can read their own posts)
      can :read, Post, user_id: user.id

      if user.admin?  # additional permissions for administrators
        can :read, Post
      end
    end
  end
end
```

See [Defining Abilities](./docs/Defining-Abilities.md) for details on how to
define your rules.


## Check Abilities

The current user's permissions can then be checked using the `can?` and `cannot?` methods in views and controllers.

```erb
<% if can? :read, @post %>
  <%= link_to "View", @post %>
<% end %>
```

See [Checking Abilities](./docs/Checking-Abilities.md) for more information
on how you can use these helpers.

## Fetching records

One of the key features of CanCanCan, compared to other authorization libraries,
is the possibility to retrieve all the objects that the user is authorized to access.
The following:

```ruby
  Post.accessible_by(current_ability)
```

will use your rules to ensure that the user retrieves only a list of posts that can be read.
See [Fetching records](./docs/Fetching-Records.md) for details.

## Controller helpers

CanCanCan expects a `current_user` method to exist in the controller.
First, set up some authentication (such as [Devise](https://github.com/plataformatec/devise) or [Authlogic](https://github.com/binarylogic/authlogic)).
See [Changing Defaults](./docs/Changing-Defaults.md) if you need a different behavior.

### 3.1 Authorizations

The `authorize!` method in the controller will raise an exception if the user is not able to perform the given action.

```ruby
def show
  @post = Post.find(params[:id])
  authorize! :read, @post
end
```

### 3.2 Loaders

Setting this for every action can be tedious, therefore the `load_and_authorize_resource` method is provided to
automatically authorize all actions in a RESTful style resource controller.
It will use a before action to load the resource into an instance variable and authorize it for every action.

```ruby
class PostsController < ApplicationController
  load_and_authorize_resource

  def show
    # @post is already loaded and authorized
  end

  def index
    # @posts is already loaded with all posts the user is authorized to read
  end
end
```

See [Authorizing Controller Actions](./docs/Authorizing-controller-actions.md)
for more information.


### 3.3 Strong Parameters

You have to sanitize inputs before saving the record, in actions such as `:create` and `:update`.

For the `:update` action, CanCanCan will load and authorize the resource but *not* change it automatically, so the typical usage would be something like:

```ruby
def update
  if @post.update(post_params)
    # hurray
  else
    render :edit
  end
end
...

def post_params
  params.require(:post).permit(:body)
end
```

For the `:create` action, CanCanCan will try to initialize a new instance with sanitized input by seeing if your
controller will respond to the following methods (in order):

1. `create_params`
2. `<model_name>_params` such as `post_params` (this is the default convention in rails for naming your param method)
3. `resource_params` (a generically named method you could specify in each controller)

Additionally, `load_and_authorize_resource` can now take a `param_method` option to specify a custom method in the controller to run to sanitize input.

You can associate the `param_method` option with a symbol corresponding to the name of a method that will get called:

```ruby
class PostsController < ApplicationController
  load_and_authorize_resource param_method: :my_sanitizer

  def create
    if @post.save
      # hurray
    else
      render :new
    end
  end

  private

  def my_sanitizer
    params.require(:post).permit(:name)
  end
end
```

You can also use a string that will be evaluated in the context of the controller using `instance_eval` and needs to contain valid Ruby code.

    load_and_authorize_resource param_method: 'permitted_params.post'

Finally, it's possible to associate `param_method` with a Proc object which will be called with the controller as the only argument:

    load_and_authorize_resource param_method: Proc.new { |c| c.params.require(:post).permit(:name) }

See [Strong Parameters](./docs/Strong-Parameters.md) for more information.

## Handle Unauthorized Access

If the user authorization fails, a `CanCan::AccessDenied` exception will be raised.
You can catch this and modify its behavior in the `ApplicationController`.

```ruby
class ApplicationController < ActionController::Base
  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.json { head :forbidden, content_type: 'text/html' }
      format.html { redirect_to main_app.root_url, notice: exception.message }
      format.js   { head :forbidden, content_type: 'text/html' }
    end
  end
end
```

See [Exception Handling](./docs/Exception-Handling.md) for more information.


## Lock It Down

If you want to ensure authorization happens on every action in your application, add `check_authorization` to your `ApplicationController`.

```ruby
class ApplicationController < ActionController::Base
  check_authorization
end
```

This will raise an exception if authorization is not performed in an action.
If you want to skip this, add `skip_authorization_check` to a controller subclass.
See [Ensure Authorization](./docs/Ensure-Authorization.md) for more information.

## Wiki Docs

* [Defining Abilities](./docs/Defining-Abilities.md)
* [Checking Abilities](./docs/Checking-Abilities.md)
* [Authorizing Controller Actions](./docs/Authorizing-controller-actions.md)
* [Exception Handling](./docs/Exception-Handling.md)
* [Changing Defaults](./docs/Changing-Defaults.md)
* [See more](./docs)

## Mission

This repo is a continuation of the dead [CanCan](https://github.com/ryanb/cancan) project.
Our mission is to keep CanCan alive and moving forward, with maintenance fixes and new features.
Pull Requests are welcome!

Any help is greatly appreciated, feel free to submit pull-requests or open issues.


## Questions?

If you have any question or doubt regarding CanCanCan which you cannot find the solution to in the
[documentation](./docs) or our
[mailing list](http://groups.google.com/group/cancancan), please
[open a question on Stackoverflow](http://stackoverflow.com/questions/ask?tags=cancancan) with tag
[cancancan](http://stackoverflow.com/questions/tagged/cancancan)

## Bugs?

If you find a bug please add an [issue on GitHub](https://github.com/CanCanCommunity/cancancan/issues) or fork the project and send a pull request.

## Development

CanCanCan uses [appraisals](https://github.com/thoughtbot/appraisal) to test the code base against multiple versions
of Rails, as well as the different model adapters.

When first developing, you need to run `bundle install` and then `bundle exec appraisal install`, to install the different sets.

You can then run all appraisal files (like CI does), with `appraisal rake` or just run a specific set `DB='sqlite' bundle exec appraisal activerecord_5.2.2 rake`.

See the [CONTRIBUTING](./CONTRIBUTING.md) for more information.

## Special Thanks

Many thanks to the [CanCanCan contributors](https://github.com/CanCanCommunity/cancancan/contributors).
See the [CHANGELOG](https://github.com/CanCanCommunity/cancancan/blob/master/CHANGELOG.md) for the full list.
