It can be difficult to thoroughly test user permissions at the functional/integration level because there are often many branching possibilities. Since CanCanCan handles all permission logic in `Ability` classes this makes it easy to have a solid set of unit test for complete coverage.

The `can?` method can be called directly on any `Ability` (like you would in the controller or view) so it is easy to test permission logic.

```ruby
test "user can only destroy projects which they own" do
  user = User.create!
  ability = Ability.new(user)
  assert ability.can?(:destroy, Project.new(user: user))
  assert ability.cannot?(:destroy, Project.new)
end
```


## RSpec

If you are testing the `Ability` class through RSpec there is a `be_able_to` matcher available. This checks if the `can?` method returns `true`.

```ruby
require "cancan/matchers"
# ...
ability.should be_able_to(:destroy, Project.new(user: user))
ability.should_not be_able_to(:destroy, Project.new)
```

Pro way ;)

```ruby
require "cancan/matchers"
# ...
describe "User" do
  describe "abilities" do
    subject(:ability) { Ability.new(user) }
    let(:user){ nil }

    context "when is an account manager" do
      let(:user){ Factory(:accounts_manager) }

      it { is_expected.to be_able_to(:manage, Account.new) }
    end
  end
end
```

## Cucumber

By default, Cucumber will ignore the `rescue_from` call in the `ApplicationController` and report the `CanCan::AccessDenied` exception when running the features. If you want full integration testing you can change this behavior so the exception is caught by Rails. You can do so by setting this in the `env.rb` file.

```ruby
# in features/support/env.rb
ActionController::Base.allow_rescue = true
```

Alternatively, if you don't want to allow rescue on everything, you can tag individual scenarios with `@allow-rescue` tag.

```ruby
@allow-rescue
Scenario: Update Article
```

Here the `rescue_from` block will take effect only in this scenario.


## Controller Testing

If you want to test authorization functionality at the controller level one option is to log-in the user who has the appropriate permissions.

```ruby
user = User.create!(admin: true)
session[:user_id] = user.id # log in user however you like, alternatively stub `current_user` method
get :index
assert_template :index # render the template since they should have access
```

Alternatively, if you want to test the controller behaviour independently from what is inside the `Ability` class, it is easy to stub out the ability with any behaviour you want.

```ruby
def setup
  @ability = Object.new
  @ability.extend(CanCan::Ability)
  @controller.stubs(:current_ability).returns(@ability)
end

test "render index if have read ability on project" do
  @ability.can :read, Project
  get :index
  assert_template :index
end
```

If you have very complex permissions it can lead to many branching possibilities. If these are all tested in the controller layer then it can lead to slow and bloated tests. 
Instead I recommend keeping controller authorization tests light and testing the authorization functionality more thoroughly in the Ability model through unit tests as shown at the top.

## Additional Docs

* [[Defining Abilities]]
* [[Checking Abilities]]
* [[Debugging Abilities]]
* [[Ability Precedence]]