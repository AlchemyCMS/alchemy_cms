# frozen_string_literal: true

# Provides admin interface routing configuration accessors.
#
# Alchemy has some defaults for admin path and admin constraints:
#
# +Alchemy.admin_path defaults to +'admin'+
# +Alchemy.admin_constraints defaults to +{}+
#
# Anyway, you can tell Alchemy about your routing configuration:
#
#   1. The path to the admin panel - @see: Alchemy.admin_path
#   2. The constraints for the admin panel (like subdomain) - @see: Alchemy.admin_constraints
#
# A word of caution: you need to know what you are doing if you set admin_path to ''. This can cause
# routing name clashes, e.g. a page named 'dashboard' will clash with the Alchemy dashboard.
#
# == Example
#
# If you do not wish to use the default admin interface routing ('example.com/admin')
# and prefer e.g. 'hidden.example.com/backend', those are the settings you need:
#
#     # config/initializers/alchemy.rb
#     Alchemy.admin_path = 'backend'
#     Alchemy.admin_constraints = {subdomain: 'hidden'}
#
module Alchemy
  mattr_accessor :admin_path, :admin_constraints

  # Defaults
  #
  @@admin_path = 'admin'
  @@admin_constraints = {}
end
