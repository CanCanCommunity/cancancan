There are many authorization solutions available, and it is important to find one which best meets the application requirements. 

We try to keep CanCanCan minimal yet extendable so it can be used in many situations, but there are times it doesn't fit the best.

If you find the conditions hash to be too limiting I encourage you to check out [[Pundit|https://github.com/elabs/pundit]] which offers a sophisticated DSL for handling more complex permission scenarios. This allows one to generate complex database queries based on the permissions but at the cost of a more complex DSL.

Also consider, if you have very unique authorization requirements, the best choice may be to write your own solution instead of trying to shoe-horn an existing plugin.