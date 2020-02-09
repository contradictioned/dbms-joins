# frozen_string_literal: true

require 'dbms_joins/version'
require 'dbms_joins/data_characteristics'
require 'dbms_joins/query_forms'
require 'dbms_joins/optimizers/random'
require 'dbms_joins/optimizers/tree'

# The module collecting classes and methods (hopefully) usefull
# for join-related exercises in database courses.
module DbmsJoins
  class Error < StandardError; end
  # Your code goes here...
end
