CanCan provides a convenient `load_and_authorize_resource` method in the controller, but what exactly is this doing? It sets up a before filter for every action to handle the loading and authorization of the controller. Let's say we have a typical RESTful controller with that line at the top.

```ruby
class ProjectsController < ApplicationController
  load_and_authorize_resource
  # ...
end
```

It will add a before filter that has this behavior for the actions if they exist. This means you do not need to put code below in your controller.

```ruby
class ProjectsController < ApplicationController
  def index
    authorize! :index, Project
    @projects = Project.accessible_by(current_ability)
  end

  def show
    @project = Project.find(params[:id])
    authorize! :show, @project
  end

  def new
    @project = Project.new
    current_ability.attributes_for(:new, Project).each do |key, value|
      @project.send("#{key}=", value)
    end
    @project.attributes = params[:project]
    authorize! :new, @project
  end

  def create
    @project = Project.new
    current_ability.attributes_for(:create, Project).each do |key, value|
      @project.send("#{key}=", value)
    end
    @project.attributes = params[:project]
    authorize! :create, @project
  end

  def edit
    @project = Project.find(params[:id])
    authorize! :edit, @project
  end

  def update
    @project = Project.find(params[:id])
    authorize! :update, @project
  end

  def destroy
    @project = Project.find(params[:id])
    authorize! :destroy, @project
  end

  def some_other_action
    if params[:id]
      @project = Project.find(params[:id])
    else
      @projects = Project.accessible_by(current_ability)
    end
    authorize!(:some_other_action, @project || Project)
  end
end
```

The most complex behavior is inside the new and create actions. There it is setting some initial attribute values based on what the given user has permission to access. For example, if the user is only allowed to create projects where the "visible" attribute is true, then it would automatically set this upon building it.

See [[Authorizing Controller Actions]] for details on what options you can pass to the `load_and_authorize_resource`.