# CanCanCan

![CanCanCan Logo](/logo/cancancan.jpg)

[![Gem Version](https://badge.fury.io/rb/cancancan.svg)](http://badge.fury.io/rb/cancancan)
[![Travis badge](https://travis-ci.org/CanCanCommunity/cancancan.svg?branch=develop)](https://travis-ci.org/CanCanCommunity/cancancan)
[![Code Climate Badge](https://codeclimate.com/github/CanCanCommunity/cancancan.svg)](https://codeclimate.com/github/CanCanCommunity/cancancan)

[Wiki](https://github.com/CanCanCommunity/cancancan/wiki) | 
[RDocs](http://rdoc.info/projects/CanCanCommunity/cancancan) | 
[Screencast 1](http://railscasts.com/episodes/192-authorization-with-cancan) |
[Screencast 2](https://www.youtube.com/watch?v=cTYu-OjUgDw)

CanCanCan is an authorization library for Ruby >= 2.2.0 and Ruby on Rails >= 4.2 which restricts what resources a given user is allowed to access. 

All permissions can be defined in one or multiple ability files and not duplicated across controllers, views, and database queries, keeping your permissions logic in one place.

It consists of two main parts:
1. **the authorizations definition library** that allows you to define the rules, for a user,
to access different objects, and provides helpers to check for those permissions.

2. **controller helpers** that help to simplify the code in Rails Controllers by performing the loading and checking of permissions
of models for you in the controllers.

## Installation

Add this to your Gemfile: 

    gem 'cancancan', '~> 2.0'
    
and run the `bundle install` command.

For Rails < 4.2 use:

    gem 'cancancan', '~> 1.10'
   
## Getting Started

### 1. Define Abilities

User permissions are defined in an `Ability` class.

    rails g cancan:ability

See [Defining Abilities](https://github.com/CanCanCommunity/cancancan/wiki/defining-abilities) for details.


### 2. Check Abilities

The current user's permissions can then be checked using the `can?` and `cannot?` methods in views and controllers.

```erb
<% if can? :update, @article %>
  <%= link_to "Edit", edit_article_path(@article) %>
<% end %>
```

See [Checking Abilities](https://github.com/CanCanCommunity/cancancan/wiki/checking-abilities) for more information

### 3. Controller helpers

CanCanCan expects a `current_user` method to exist in the controller.
First, set up some authentication (such as [Devise](https://github.com/plataformatec/devise) or [Authlogic](https://github.com/binarylogic/authlogic)).
See [Changing Defaults](https://github.com/CanCanCommunity/cancancan/wiki/changing-defaults) if you need a different behavior.

### 3.1 Authorizations

The `authorize!` method in the controller will raise an exception if the user is not able to perform the given action.

```ruby
def show
  @article = Article.find(params[:id])
  authorize! :read, @article
end
```

### 3.1 Loaders

Setting this for every action can be tedious, therefore the `load_and_authorize_resource` method is provided to 
automatically authorize all actions in a RESTful style resource controller. 
It will use a before action to load the resource into an instance variable and authorize it for every action.

```ruby
class ArticlesController < ApplicationController
  load_and_authorize_resource

  def show
    # @article is already loaded and authorized
  end
end
```

See [Authorizing Controller Actions](https://github.com/CanCanCommunity/cancancan/wiki/authorizing-controller-actions)
for more information.


### 3.2 Strong Parameters

You have to sanitize inputs before saving the record, in actions such as `:create` and `:update`.

For the `:update` action, CanCanCan will load and authorize the resource but *not* change it automatically, so the typical usage would be something like:

```ruby
def update
  if @article.update_attributes(update_params)
    # hurray
  else
    render :edit
  end
end
...

def update_params
  params.require(:article).permit(:body)
end
```

For the `:create` action, CanCanCan will try to initialize a new instance with sanitized input by seeing if your 
controller will respond to the following methods (in order):

1. `create_params`
2. `<model_name>_params` such as `article_params` (this is the default convention in rails for naming your param method)
3. `resource_params` (a generically named method you could specify in each controller)

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

You can also use a string that will be evaluated in the context of the controller using `instance_eval` and needs to contain valid Ruby code. 

    load_and_authorize_resource param_method: 'permitted_params.article'

Finally, it's possible to associate `param_method` with a Proc object which will be called with the controller as the only argument:

    load_and_authorize_resource param_method: Proc.new { |c| c.params.require(:article).permit(:name) }

See [Strong Parameters](https://github.com/CanCanCommunity/cancancan/wiki/Strong-Parameters) for more information.

### 4. Handle Unauthorized Access

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

See [Exception Handling](https://github.com/CanCanCommunity/cancancan/wiki/exception-handling) for more information.


### 5. Lock It Down

If you want to ensure authorization happens on every action in your application, add `check_authorization` to your `ApplicationController`.

```ruby
class ApplicationController < ActionController::Base
  check_authorization
end
```

This will raise an exception if authorization is not performed in an action. 
If you want to skip this, add `skip_authorization_check` to a controller subclass. 
See [Ensure Authorization](https://github.com/CanCanCommunity/cancancan/wiki/Ensure-Authorization) for more information.

## Version 2.0

Version 2.0 drops support for Mongoid and Sequel. 

Please use `gem 'cancancan', '~> 1.10'` for them.

If you are interested in supporting them, contribute to the sibling gems `cancancan-sequel` and `cancancan-mongoid`.

Version 2.0 drops also support for Rails < 4.2 and ruby < 2.2 so, again, use the version 1 of the Gem for these.


## Wiki Docs

* [Defining Abilities](https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities)
* [Checking Abilities](https://github.com/CanCanCommunity/cancancan/wiki/Checking-Abilities)
* [Authorizing Controller Actions](https://github.com/CanCanCommunity/cancancan/wiki/Authorizing-Controller-Actions)
* [Exception Handling](https://github.com/CanCanCommunity/cancancan/wiki/Exception-Handling)
* [Changing Defaults](https://github.com/CanCanCommunity/cancancan/wiki/Changing-Defaults)
* [See more](https://github.com/CanCanCommunity/cancancan/wiki)

## Mission

This repo is a continuation of the dead [CanCan](https://github.com/ryanb/cancan) project. 
Our mission is to keep CanCan alive and moving forward, with maintenance fixes and new features. 
Pull Requests are welcome!

Any help is greatly appreciated, feel free to submit pull-requests or open issues.


## Questions?

If you have any question or doubt regarding CanCanCan which you cannot find the solution to in the 
[documentation](https://github.com/CanCanCommunity/cancancan/wiki) or our 
[mailing list](http://groups.google.com/group/cancancan), please 
[open a question on Stackoverflow](http://stackoverflow.com/questions/ask?tags=cancancan) with tag 
[cancancan](http://stackoverflow.com/questions/tagged/cancancan)

## Bugs?

If you find a bug please add an [issue on GitHub](https://github.com/CanCanCommunity/cancancan/issues) or fork the project and send a pull request.


## Development

CanCanCan uses [appraisals](https://github.com/thoughtbot/appraisal) to test the code base against multiple versions 
of Rails, as well as the different model adapters.

When first developing, you need to run `bundle install` and then `appraisal install`, to install the different sets.

You can then run all appraisal files (like CI does), with `appraisal rake` or just run a specific set `appraisal activerecord_5.0 rake`.

See the [CONTRIBUTING](https://github.com/CanCanCommunity/cancancan/blob/develop/CONTRIBUTING.md) and 
[spec/README](https://github.com/CanCanCommunity/cancancan/blob/master/spec/README.rdoc) for more information.


## Special Thanks

[![Renuo AG](/logo/renuo.png)](https://www.renuo.ch)

Thanks to [Renuo AG](https://www.renuo.ch) for currently maintaining and supporting the project.

Also many thanks to the [CanCanCan contributors](https://github.com/CanCanCommunity/cancancan/contributors). 
See the [CHANGELOG](https://github.com/CanCanCommunity/cancancan/blob/master/CHANGELOG.rdoc) for the full list.

CanCanCan was inspired by [declarative_authorization](https://github.com/stffn/declarative_authorization/) and 
[aegis](https://github.com/makandra/aegis). 


