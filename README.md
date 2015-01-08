# CanCanCan

[![Gem Version](https://badge.fury.io/rb/cancancan.svg)](http://badge.fury.io/rb/cancancan)
[![Travis badge](https://travis-ci.org/CanCanCommunity/cancancan.png?branch=master)](https://travis-ci.org/CanCanCommunity/cancancan)
[![Code Climate Badge](https://codeclimate.com/github/CanCanCommunity/cancancan.png)](https://codeclimate.com/github/CanCanCommunity/cancancan)
[![Inch CI](http://inch-ci.org/github/CanCanCommunity/cancancan.png)](http://inch-ci.org/github/CanCanCommunity/cancancan)

[Wiki](https://github.com/CanCanCommunity/cancancan/wiki) | [RDocs](http://rdoc.info/projects/CanCanCommunity/cancan) | [Screencast](http://railscasts.com/episodes/192-authorization-with-cancan)

CanCan is an authorization library for Ruby on Rails which restricts what resources a given user is allowed to access. All permissions are defined in a single location (the `Ability` class) and not duplicated across controllers, views, and database queries.


## Mission

This repo is a continuation of the dead [CanCan](https://github.com/ryanb/cancan) project. Our mission is to keep CanCan alive and moving forward, with maintenance fixes and new features. Pull Requests are welcome!

I am currently focusing on the 1.x branch for the immediate future, making sure it is up to date as well as ensuring compatibility with Rails 4+. I will take a look into the 2.x branch and try to see what improvements, reorganizations and redesigns Ryan was attempting and go forward from there.

Any help is greatly appreciated, feel free to submit pull-requests or open issues.


## Installation

In **Rails 3 and 4**, add this to your Gemfile and run the `bundle install` command.

    gem 'cancancan', '~> 1.10'

In **Rails 2**, add this to your environment.rb file.

    config.gem "cancancan"

Alternatively, you can install it as a plugin.

    rails plugin install git://github.com/CanCanCommunity/cancancan.git

## Getting Started

CanCanCan expects a `current_user` method to exist in the controller. First, set up some authentication (such as [Authlogic](https://github.com/binarylogic/authlogic) or [Devise](https://github.com/plataformatec/devise)). See [Changing Defaults](https://github.com/CanCanCommunity/cancancan/wiki/changing-defaults) if you need different behavior.


### 1. Define Abilities

User permissions are defined in an `Ability` class. CanCan 1.5 includes a Rails 3 and 4 generator for creating this class.

    rails g cancan:ability

In Rails 2.3, just add a new class in `app/models/ability.rb` with the following contents:

```ruby
class Ability
  include CanCan::Ability

  def initialize(user)
  end
end
```

See [Defining Abilities](https://github.com/CanCanCommunity/cancancan/wiki/defining-abilities) for details.


### 2. Check Abilities & Authorization

The current user's permissions can then be checked using the `can?` and `cannot?` methods in the view and controller.

```erb
<% if can? :update, @article %>
  <%= link_to "Edit", edit_article_path(@article) %>
<% end %>
```

See [Checking Abilities](https://github.com/CanCanCommunity/cancancan/wiki/checking-abilities) for more information

The `authorize!` method in the controller will raise an exception if the user is not able to perform the given action.

```ruby
def show
  @article = Article.find(params[:id])
  authorize! :read, @article
end
```

Setting this for every action can be tedious, therefore the `load_and_authorize_resource` method is provided to automatically authorize all actions in a RESTful style resource controller. It will use a before filter to load the resource into an instance variable and authorize it for every action.

```ruby
class ArticlesController < ApplicationController
  load_and_authorize_resource

  def show
    # @article is already loaded and authorized
  end
end
```

See [Authorizing Controller Actions](https://github.com/CanCanCommunity/cancancan/wiki/authorizing-controller-actions) for more information.


#### Strong Parameters

When using `strong_parameters` or Rails 4+, you have to sanitize inputs before saving the record, in actions such as `:create` and `:update`.

By default, CanCan will try to sanitize the input on `:create` and `:update` routes by seeing if your controller will respond to the following methods (in order):

* `create_params` or `update_params` (depending on the action you are performing)
* `<model_name>_params` such as `article_params` (this is the default convention in rails for naming your param method)
* `resource_params` (a generically named method you could specify in each controller)

Additionally, `load_and_authorize_resource` can now take a `param_method` option to specify a custom method in the controller to run to sanitize input.

You can associate the `param_method` option with a symbol corresponding to the name of a method that will get called:

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

You can also use a string that will be evaluated in the context of the controller using `instance_eval` and needs to contain valid Ruby code. This does come in handy when using a PermittedParams class as suggested in Railscast 371:

    load_and_authorize_resource param_method: 'permitted_params.article'

Finally, it's possible to associate `param_method` with a Proc object which will be called with the controller as the only argument:

    load_and_authorize_resource param_method: Proc.new { |c| c.params.require(:article).permit(:name) }

See [Strong Parameters](https://github.com/CanCanCommunity/cancancan/wiki/Strong-Parameters) for more information.

### 3. Handle Unauthorized Access

If the user authorization fails, a `CanCan::AccessDenied` exception will be raised. You can catch this and modify its behavior in the `ApplicationController`.

```ruby
class ApplicationController < ActionController::Base
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => exception.message
  end
end
```

See [Exception Handling](https://github.com/CanCanCommunity/cancancan/wiki/exception-handling) for more information.


### 4. Lock It Down

If you want to ensure authorization happens on every action in your application, add `check_authorization` to your `ApplicationController`.

```ruby
class ApplicationController < ActionController::Base
  check_authorization
end
```

This will raise an exception if authorization is not performed in an action. If you want to skip this add `skip_authorization_check` to a controller subclass. See [Ensure Authorization](https://github.com/CanCanCommunity/cancancan/wiki/Ensure-Authorization) for more information.


## Wiki Docs

* [Upgrading to 1.6](https://github.com/CanCanCommunity/cancancan/wiki/Upgrading-to-1.6)
* [Defining Abilities](https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities)
* [Checking Abilities](https://github.com/CanCanCommunity/cancancan/wiki/Checking-Abilities)
* [Authorizing Controller Actions](https://github.com/CanCanCommunity/cancancan/wiki/Authorizing-Controller-Actions)
* [Exception Handling](https://github.com/CanCanCommunity/cancancan/wiki/Exception-Handling)
* [Changing Defaults](https://github.com/CanCanCommunity/cancancan/wiki/Changing-Defaults)
* [See more](https://github.com/CanCanCommunity/cancancan/wiki)

## Questions or Problems?

If you have any issues with CanCan which you cannot find the solution to in the [documentation](https://github.com/CanCanCommunity/cancancan/wiki) or our mailing list: http://groups.google.com/group/cancancan, please add an [issue on GitHub](https://github.com/CanCanCommunity/cancancan/issues) or fork the project and send a pull request.


## Development

Cancancan uses [appraisals](https://github.com/thoughtbot/appraisal) to test the code base against multiple versions of rails, as well as the different model adapters.

When first developing, you may need to run `bundle install` and then `appraisal install`, to install the different sets.

You can then run all appraisal files (like CI does), with `appraisal rake` or just run a specific set `appraisal activerecord_3.0 rake`.

See the [CONTRIBUTING](https://github.com/CanCanCommunity/cancancan/blob/develop/CONTRIBUTING.md) and [spec/README](https://github.com/CanCanCommunity/cancancan/blob/master/spec/README.rdoc) for more information.


## Special Thanks

CanCan was inspired by [declarative_authorization](https://github.com/stffn/declarative_authorization/) and [aegis](https://github.com/makandra/aegis). Also many thanks to the [CanCan contributors](https://github.com/CanCanCommunity/cancancan/contributors). See the [CHANGELOG](https://github.com/CanCanCommunity/cancancan/blob/master/CHANGELOG.rdoc) for the full list.
