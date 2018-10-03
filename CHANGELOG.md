## 2.3.0 (Sep 16th, 2018)

* [#528](https://github.com/CanCanCommunity/cancancan/issues/528): Compress irrelevant rules before generating a query to optimize performances. ([@coorasse][])
* [#529](https://github.com/CanCanCommunity/cancancan/issues/529): Remove ruby 2.2 from Travis and add ruby 2.5.1. ([@coorasse][])
* [#530](https://github.com/CanCanCommunity/cancancan/issues/530): Predict associations names to support multiple references to the same table. ([@coorasse][])
* [#530](https://github.com/CanCanCommunity/cancancan/issues/530): Raise a specific exception when using a wrong association name in rules definition. ([@coorasse][])

## 2.2.0 (Apr 13th, 2018)

* [#482](https://github.com/CanCanCommunity/cancancan/issues/482): Include conditions passed to authorize! in AccessDenied exception. ([@kraflab][])
* Removed support for dynamic finders. ([@coorasse][])
* [#479](https://github.com/CanCanCommunity/cancancan/issues/479): Support Rails 5.2. ([@lizzyaustad][])
* Use ActiveSupport standard loader. ([@BookOfGreg][])

## 2.1.4 (Apr 09th, 2018)

* Inject cancancan in ActionController::API and ActionController::Base when they are both defined. ([@arturoherrero][])

## 2.1.3 (Jan 16th, 2018)

* Fix compatibility with Rails 5 API. ([@Eric-Guo][])

## 2.1.2 (Nov 22th, 2017)

* Various bugfixes on version 2.1.0. ([@coorasse][])

## 2.1.0 (Nov 10th, 2017)

* Adds support for Rails Api applications. ([@ajgon][])
* Controller subclasses inherit skip_load_resource from superclass. ([@jpmckinney][])
* Fix instance variable not initialized warnings. ([@sethcharles][])
* Fix build_resource when model name is Action. ([@anilmaurya][])
* Smaller performance improvements. ([@DNNX][])
* Fix i18n lookup for unauthorized message. ([@clemens][])

## 2.0.0 (May 18th, 2017)

* Drop support for Rails < 4.2. ([@oliverklee][])
* Drop support for ruby < 2.2. ([@coorasse][])
* Drop support for InheritedResource. ([@coorasse][])
* Drop support for Sequel. ([@coorasse][])
* Drop support for Mongoid. ([@coorasse][])
* Add ability to rspec matcher to take array of abilities. ([@gingray][])
* [#204](https://github.com/CanCanCommunity/cancancan/pull/204): Increase Performance. ([@timraymond][])
* Removed controller methods: skip_authorization, unauthorized!. ([@coorasse][])
* Removed options: nested, name, resource. ([@coorasse][])

## 1.17.0 (March 26th, 2017)

* Improve performance for the Mongoid Adapter.


## 1.16.0 (February 2nd, 2017)

* Introduce rubocop and fixes most of the issues ([@coorasse][]).

## 1.15.0 (June 13th, 2016)

* Add support for Rails 5 (craig1410).

## 1.14.0 (May 14th, 2016)

* Use cover for ranges.
* Add support for rails 4 enum's (markpmitchell).

## 1.13.1 (Oct 8th, 2015)

* Fix #merge with empty Ability (jhawthorn).

## 1.13.0 (Oct 7th, 2015)

* Significantly improve rule lookup time (amarshall).
* Removed deprecation warnings for RSpec 3.2 (NekoNova).
* Drop support for REE and Ruby 1.x and so Rails 2 (Richard Wilson).

## 1.12.0 (June 28th, 2015)

* Add a permissions method to Ability (devaroop).

## 1.11.0 (June 15th, 2015)

* Complete cancancan#115 - Specify authorization action for parent resources. (phallguy).

## 1.10.1 (January 13th, 2015)

* Fix cancancan#168 - A bug with ActiveRecord 4.2 support causing ProtocolViolation due to named parameters not being passed in.


## 1.10.0 (January 7th, 2015)

* Fix i18n issue for Ruby < 1.9.3 ([@bryanrite][]).

* Fix cancancan#149 - Fix an issue loading namespaced models (darthjee).

* Fix cancancan#160 - Support for Rails 4.2 (marshall-lee).

* Fix cancancan#153 - More useful output in ability spec matchers (jondkinney).


## 1.9.2 (August 8th, 2014)

* Fix cancancan#77, 78 - Fix an issue with associations for namespaced models (jjp).


## 1.9.1 (July 21st, 2014)

* Fix cancancan#101 - Fixes an issue where overjealous use of references would cause issues with scopes when loading associations ([@bryanrite][]).


## 1.9.0 (July 20th, 2014)

* Fix cancancan#59 - Parameters are automatically detected and santitized for all actions, not just create and update ([@bryanrite][]).

* Fix cancancan#97, 72, 40, 39, 26 - Support Active Record 4 properly with references on nested permissions (scpike, tdg5, Crystark).


## 1.8.4 (June 24th, 2014)

* Fix cancancan#86 - Fixes previous RSpec 3 update as there was a bug in the fix for RSpec 2.99 ([@bryanrite][]).


## 1.8.3 (June 24th, 2014)

* Fix cancancan#85 - Remove deprecation notices for RSpec 3 and continue backwards compatibility (andypike, bryanrite, porteta).


## 1.8.2 (June 5th, 2014)

* Fix cancancan#75 - More specific hash-like object check. ([@bryanrite][]).


## 1.8.1 (May 27th, 2014)

* Fix cancancan#67 - Sequel tests are run properly for JRuby. ([@bryanrite][]).

* Fix cancancan#68 - Checks for hash-like objects in subject better. ([@bryanrite][]).


## 1.8.0 (May 8th, 2014)

* Feature cancan#884 - Add a Sequel model adapter (szetobo).

* Feature cancancan#3 - Permit "can?" check multiple subjects (cefigueiredo).

* Feature cancancan#29 - Add ability to use a String that will get instance_eval'd or a Proc that will get called as the parameter method option for strong_parameter santization (svoop).

* Feature cancancan#48 - Define a CanCanCan module. Even though it is not used, it is standard practice to define the module, and helpful for determining between CanCanCan and CanCan for external libraries.


## 1.7.1 (March 19th, 2014)

* Fix ryanb/cancan#992 - Remove Rails 4 deprecations for scoped (thejchap & hitendrasingh).

* Fix cancancan#16 - RSpec expectations are not explicitly required in RSpec > 2.13 (justinaiken & bryanrite).


## 1.7.0 (February 19th, 2014)

* Feature #988 Adds support for strong_parameters ([@bryanrite][]).

* Fix #726 - Allow multiple abilities with associations (elabs-dev).

* Fix #864 - Fix id_param in shallow routes (francocatena).

* Fix #871 - Fixes nested ability conditions (ricec).

* Fix #935 - Reduce unnecessary object allocations (grosser).

* Fix #966 - Fixes a variable name collision in nested conditions (knoopx).

* Fix #971 - Does not execute "empty?" scope when checking class rule (matt-glover).

* Fix #974 - Avoid unnecessary sql execution (inkstak).


## 1.6.10 (May 7, 2013)

* Fix matches_conditons_hash for string values on 1.8 ([@rrosen][]).

* Work around SQL injection vulnerability in older Rails versions ([@steerio][]) - issue #800.

* Add support for nested join conditions ([@yuszuv][]) - issue #806.

* Fix load_resource "find_by" in mongoid resources ([@albertobajo][]) - issue #705.

* Fix namespace split behavior ([@xinuc][]) - issue #668.


## 1.6.9 (February 4, 2013)

* Fix inserting AND (NULL) to end of SQL queries (jonsgreen) - issue #687.

* Fix merge_joins for nested association hashes (DavidMikeSimon) - issues #655, #560.

* Raise error on recursive alias_action (fl00r) - issue #660.

* Fix namespace controllers not loading params (andhapp) - issues #670, #664.


## 1.6.8 (June 25, 2012)

* Improved support for namespaced controllers and models.

* Pass :if and :unless options for load and authorize resource (mauriciozaffari).

* Travis CI badge (plentz).

* Adding Ability#merge for combining multiple abilities (rogercampos).

* Support for multiple MetaWhere rules (andhapp).

* Various fixes for DataMapper, Mongoid, and Inherited Resource integration.

* {see the full list of changes}[https://github.com/CanCanCommunity/cancancan/compare/1.6.7...1.6.8].


## 1.6.7 (October 4, 2011)

* Fixing nested resource problem caused by namespace addition - issue #482.

* {see the full list of changes}[https://github.com/CanCanCommunity/cancancan/compare/1.6.6...1.6.7].


## 1.6.6 (September 28, 2011)

* Correct "return cant jump across threads" error when using check_authorization (codeprimate) - issues #463, #469.

* Fixing tests in development by specifying with_model version  (kirkconnell) - issue #476.

* Added travis.yml file for TravisCI support (bai) - issue #427.

* Better support for namespaced models (whilefalse) - issues #424.

* Adding :id_param option to load_and_authorize_resource (skhisma) - issue #425.

* Make default unauthorized message translatable text (nhocki) - issue #409.

* Improving DataMapper behavior (psanford, maxsum-corin) - issue #410, #373.

* Allow :find_by option to be full find method name - issue #335.

* {see the full list of changes}[https://github.com/CanCanCommunity/cancancan/compare/1.6.5...1.6.6].


## 1.6.5 (May 18, 2011)

* [#366](https://github.com/CanCanCommunity/cancancan/issues/366): Pass action and subject through AccessDenied exception when :through isn't found.

* Many Mongoid adapter improvements (rahearn, cardagin) - issues #363, #352, #343.

* [#360](https://github.com/CanCanCommunity/cancancan/issues/360): Allow :through option to work with private controller methods.

* [#359](https://github.com/CanCanCommunity/cancancan/issues/359): Ensure Mongoid::Document is defined before loading Mongoid adapter.

* [#355](https://github.com/CanCanCommunity/cancancan/issues/355): Many DataMapper adapter improvements ([@emmanuel][]).

* [#330](https://github.com/CanCanCommunity/cancancan/issues/330): Handle checking nil attributes through associations ([@thatothermitch][]).

* Improve scope merging - issue #328.

* {see the full list of changes}[https://github.com/CanCanCommunity/cancancan/compare/1.6.4...1.6.5].


## 1.6.4 (March 29, 2011)

* Fixed mongoid 'or' error - see issue #322.

* {see the full list of changes}[https://github.com/CanCanCommunity/cancancan/compare/1.6.3...1.6.4].


## 1.6.3 (March 25, 2011)

* Make sure ActiveRecord::Relation is defined before checking conditions against it so Rails 2 is supported again - see issue #312.

* Return subject passed to authorize! - see issue #314.

* {see the full list of changes}[https://github.com/CanCanCommunity/cancancan/compare/1.6.2...1.6.3].


## 1.6.2 (March 18, 2011)

* Fixed instance loading when :singleton option is used - see issue #310.

* {see the full list of changes}[https://github.com/CanCanCommunity/cancancan/compare/1.6.1...1.6.2].


## 1.6.1 (March 15, 2011)

* Use Item.new instead of build_item for singleton resource so it doesn't effect database - see issue #304.

* Made accessible_by action default to :index and parent action default to :show instead of :read - see issue #302.

* Reverted Inherited Resources "collection" override since it doesn't seem to be working - see issue #305.

* {see the full list of changes}[https://github.com/CanCanCommunity/cancancan/compare/1.6.0...1.6.1].


## 1.6.0 (March 11, 2011)

* Added MetaWhere support - see issue #194 and #261.

* Allow Active Record scopes in Ability conditions - see issue #257.

* Added :if and :unless options to check_authorization - see issue #284.

* Several Inherited Resources fixes (aq1018, tanordheim and stefanoverna).

* Pass action name to accessible_by call when loading a collection ([@amw][]).

* Added :prepend option to load_and_authorize_resource to load before other filters - see issue #290.

* Fixed spacing issue in I18n message for multi-word model names - see issue #292.

* Load resource collection for any action which doesn't have an "id" parameter - see issue #296.

* Raise an exception when trying to make a Ability condition with both a hash of conditions and a block - see issue #269.

* {see the full list of changes}[https://github.com/CanCanCommunity/cancancan/compare/1.5.1...1.6.0].


## 1.5.1 (January 20, 2011)

* Fixing deeply nested conditions in Active Record adapter - see issue #246.

* Improving Mongoid support for multiple can and cannot definitions ([@stellard][]) - see issue #239.

* {see the full list of changes}[https://github.com/CanCanCommunity/cancancan/compare/1.5.0...1.5.1].


## 1.5.0 (January 11, 2011)

* Added an Ability generator - see issue #170.

* Added DataMapper support ([@natemueller][]).

* Added Mongoid support ([@bowsersenior][]).

* Added skip_load_and_authorize_resource methods to controller class - see issue #164.

* Added support for uncountable resources in index action - see issue #193.

* Cleaned up README and added spec/README.

* Internal: renamed CanDefinition to Rule.

* Internal: added a model adapter layer for easily supporting more ORMs.

* Internal: added .rvmrc to auto-switch to 1.8.7 with gemset - see issue #231.

* {see the full list of changes}[https://github.com/CanCanCommunity/cancancan/compare/1.4.1...1.5.0].


## 1.4.1 (November 12, 2010)

* Renaming skip_authorization to skip_authorization_check - see issue #169.

* Adding :through_association option to load_resource ([@hunterae][]) - see issue #171.

* The :shallow option now works with the :singleton option ([@nandalopes][]) - see issue #187.

* Play nicely with quick_scopes gem ([@ramontayag][]) - see issue #183.

* Fix odd behavior when "cache_classes = false" ([@mphalliday][]) - see issue #174.

* {see the full list of changes}[https://github.com/CanCanCommunity/cancancan/compare/1.4.0...1.4.1].


## 1.4.0 (October 5, 2010)

* Adding Gemfile; to get specs running just +bundle+ and +rake+ - see issue #163.

* Stop at 'cannot' definition when there are no conditions - see issue #161.

* The :through option will now call a method with that name if instance variable doesn't exist - see issue #146.

* Adding :shallow option to load_resource to bring back old behavior of fetching a child without a parent.

* Raise AccessDenied error when loading a child and parent resource isn't found.

* Abilities defined on a module will apply to anything that includes that module - see issue #150 and #152.

* Abilities can be defined with a string of SQL in addition to a block so accessible_by works with a block - see issue #150.

* Adding better support for InheritedResource - see issue #23.

* Loading the collection instance variable (for index action) using accessible_by - see issue #137.

* Adding action and subject variables to I18n unauthorized message - closes #142.

* Adding check_authorization and skip_authorization controller class methods to ensure authorization is performed ([@justinko][]) - see issue #135.

* Setting initial attributes based on ability conditions in new/create actions - see issue #114.

* Check parent attributes for nested association in index action - see issue #121.

* Supporting nesting in can? method using hash - see issue #121.

* Adding I18n support for Access Denied messages ([@EppO][]) - see issue #103.

* Passing no arguments to +can+ definition will pass action, class, and object to block - see issue #129.

* Don't pass action to block in +can+ definition when using :+manage+ option - see issue #129.

* No longer calling block in +can+ definition when checking on class - see issue #116.

* {see the full list of changes}[https://github.com/CanCanCommunity/cancancan/compare/1.3.4...1.4.0].


## 1.3.4 (August 31, 2010)

* Don't stop at +cannot+ with hash conditions when checking class ([@tamoya][]) - see issue #131.

* {see the full list of changes}[https://github.com/CanCanCommunity/cancancan/compare/1.3.3...1.3.4].


## 1.3.3 (August 20, 2010)

* Switching to Rspec namespace to remove deprecation warning in Rspec 2 - see issue #119.

* Pluralize nested associations for conditions in accessible_by ([@mlooney][]) - see issue #123.

* {see the full list of changes}[https://github.com/CanCanCommunity/cancancan/compare/1.3.2...1.3.3].


## 1.3.2 (August 7, 2010)

* Fixing slice error when passing in custom resource name - see issue #112.

* {see the full list of changes}[https://github.com/CanCanCommunity/cancancan/compare/1.3.1...1.3.2].


## 1.3.1 (August 6, 2010)

* Fixing protected sanitize_sql error - see issue #111.

* {see the full list of changes}[https://github.com/CanCanCommunity/cancancan/compare/1.3.0...1.3.1].


## 1.3.0 (August 6, 2010)

* Adding :find_by option to load_resource - see issue #19.

* Adding :singleton option to load_resource - see issue #93.

* Supporting multiple resources in :through option for polymorphic associations - see issue #73.

* Supporting Single Table Inheritance for "can" comparisons - see issue #55.

* Adding :instance_name option to load/authorize_resource - see issue #44.

* Don't pass nil to "new" to keep MongoMapper happy - see issue #63.

* Parent resources are now authorized with :read action.

* Changing :resource option in load/authorize_resource back to :class with ability to pass false.

* Removing :nested option in favor of :through option with separate load/authorize call.

* Moving internal logic from ResourceAuthorization to ControllerResource class.

* Supporting multiple "can" and "cannot" calls with accessible_by (funny-falcon) - see issue #71.

* Supporting deeply nested aliases - see issue #98.

* {see the full list of changes}[https://github.com/CanCanCommunity/cancancan/compare/1.2.0...1.3.0].


## 1.2.0 (July 16, 2010)

* Load nested parent resources on collection actions such as "index" (dohzya).

* Adding :name option to load_and_authorize_resource if it does not match controller - see issue #65.

* Fixing issue when using accessible_by with nil can conditions (jrallison) - see issue #66.

* Pluralize table name for belongs_to associations in can conditions hash (logandk) - see issue #62.

* Support has_many association or arrays in can conditions hash.

* Adding joins clause to accessible_by when conditions are across associations.

* {see the full list of changes}[https://github.com/CanCanCommunity/cancancan/compare/1.1.1...1.2.0].


## 1.1.1 (April 17, 2010)

* Fixing behavior in Rails 3 by properly initializing ResourceAuthorization.

* {see the full list of changes}[https://github.com/CanCanCommunity/cancancan/compare/1.1...1.1.1].


## 1.1.0 (April 17, 2010)

* Supporting arrays, ranges, and nested hashes in ability conditions.

* Removing "unauthorized!" method in favor of "authorize!" in controllers.

* Adding action, subject and default_message abilities to AccessDenied exception - see issue #40.

* Adding caching to current_ability controller method, if you're overriding this be sure to add caching too.

* Adding "accessible_by" method to Active Record for fetching records matching a specific ability.

* Adding conditions behavior to Ability#can and fetch with Ability#conditions - see issue #53.

* Renaming :class option to :resource for load_and_authorize_resource which now supports a symbol for non models - see issue #45.

* Properly handle Admin::AbilitiesController in params[:controller] - see issue #46.

* Adding be_able_to RSpec matcher (dchelimsky), requires Ruby 1.8.7 or higher - see issue #54.

* Support additional arguments to can? which get passed to the block - see issue #48.

* {see the full list of changes}[https://github.com/CanCanCommunity/cancancan/compare/1.0.2...1.1].


## 1.0.2 (Dec 30, 2009)

* Adding clear_aliased_actions to Ability which removes previously defined actions including defaults - see issue #20.

* Append aliased actions (don't overwrite them) - see issue #20.

* Adding custom message argument to unauthorized! method (tjwallace) - see issue #18.

* {see the full list of changes}[https://github.com/CanCanCommunity/cancancan/compare/1.0.1...1.0.2].


## 1.0.1 (Dec 14, 2009)

* Adding :class option to load_resource so one can customize which class to use for the model - see issue #17.

* Don't fetch parent of nested resource if *_id parameter is missing so it works with shallow nested routes - see issue #14.

* {see the full list of changes}[https://github.com/CanCanCommunity/cancancan/compare/1.0.0...1.0.1].


## 1.0.0 (Dec 13, 2009)

* Don't set resource instance variable if it has been set already - see issue #13.

* Allowing :nested option to accept an array for deep nesting.

* Adding :nested option to load resource method - see issue #10.

* Pass :only and :except options to before filters for load/authorize resource methods.

* Adding :collection and :new options to load_resource method so we can specify behavior of additional actions if needed.

* BACKWARDS INCOMPATIBLE: turning load and authorize resource methods into class methods which set up the before filter so they can accept additional arguments.

* {see the full list of changes}[https://github.com/CanCanCommunity/cancancan/compare/0.2.1...1.0.0].


## 0.2.1 (Nov 26, 2009)

* Many internal refactorings - see issues #11 and #12.

* Adding "cannot" method to define which abilities cannot be done - see issue #7.

* Support custom objects (usually symbols) in can definition - see issue #8.

* See the full list of changes [https://github.com/CanCanCommunity/cancancan/compare/0.2.0...0.2.1].


## 0.2.0 (Nov 17, 2009)

* Fix behavior of load_and_authorize_resource for namespaced controllers - see issue #3.

* Support arrays being passed to "can" to specify multiple actions or classes - see issue #2.

* Adding "cannot?" method to ability, controller, and view which is inverse of "can?" - see issue #1.

* BACKWARDS INCOMPATIBLE: use Ability#initialize instead of 'prepare' to set up abilities - see issue #4.

* See the full list of changes [https://github.com/CanCanCommunity/cancancan/compare/0.1.0...0.2.0].


## 0.1.0 (Nov 16, 2009)

* Initial release.

[@coorasse]: https://github.com/coorasse
[@kraflab]: https://github.com/kraflab
[@lizzyaustad]: https://github.com/lizzyaustad
[@kevintyll]: https://github.com/kevintyll
[@BookOfGreg]: https://github.com/BookOfGreg
[@arturoherrero]: https://github.com/arturoherrero
[@Eric-Guo]: https://github.com/Eric-Guo
[@ajgon]: https://github.com/ajgon
[@jpmckinney]: https://github.com/jpmckinney
[@sethcharles]: https://github.com/sethcharles
[@anilmaurya]: https://github.com/anilmaurya
[@DNNX]: https://github.com/DNNX
[@clemens]: https://github.com/clemens
[@bryanrite]: https://github.com/bryanrite
[@emmanuel]: https://github.com/emmanuel
[@thatothermitch]: https://github.com/thatothermitch
[@amw]: https://github.com/amw
[@stellard]: https://github.com/stellard
[@natemueller]: https://github.com/natemueller
[@bowsersenior]: https://github.com/bowsersenior
[@hunterae]: https://github.com/hunterae
[@nandalopes]: https://github.com/nandalopes
[@ramontayag]: https://github.com/ramontayag
[@mphalliday]: https://github.com/mphalliday
[@justinko]: https://github.com/justinko
[@EppO]: https://github.com/EppO
[@tamoya]: https://github.com/tamoya
[@mlooney]: https://github.com/mlooney
[@rrosen]: https://github.com/rrosen
[@steerio]: https://github.com/steerio
[@yuszuv]: https://github.com/yuszuv
[@albertobajo]: https://github.com/albertobajo
[@xinuc]: https://github.com/xinuc
[@oliverklee]: https://github.com/oliverklee
[@gingray]: https://github.com/gingray
[@timraymond]: https://github.com/timraymond
