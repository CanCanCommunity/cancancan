= CanCanCan Specs

== Running the specs

To run the specs first run the +bundle+ command to install the necessary gems.

  bundle

Then run the appraisal command to install all the necessary test sets.

  bundle exec appraisal install

You can then run all test sets:

  bundle exec appraisal rspec

Or individual ones:

  bundle exec appraisal activerecord_5.2.0 rspec
