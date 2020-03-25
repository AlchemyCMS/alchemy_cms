# frozen_string_literal: true
# Instantiate the global Alchemy namespace
module Alchemy
  Alchemy::YAML_WHITELIST_CLASSES = %w(Symbol Date Regexp)
end

# Require globally used external libraries
require 'acts_as_list'
require 'action_view/dependency_tracker'
require 'active_model_serializers'
require 'awesome_nested_set'
require 'cancan'
require 'dragonfly'
require 'gutentag'
require 'handlebars_assets'
require 'jquery-rails'
require 'jquery-ui-rails'
require 'kaminari'
require 'non-stupid-digest-assets'
require 'ransack'
require 'request_store'
require 'responders'
require 'sassc-rails'
require 'simple_form'
require 'select2-rails'
require 'turbolinks'
require 'userstamp'

# Require globally used Alchemy mixins
require_relative 'alchemy/ability_helper'
require_relative 'alchemy/admin/locale'
require_relative 'alchemy/auth_accessors'
require_relative 'alchemy/cache_digests/template_tracker'
require_relative 'alchemy/config'
require_relative 'alchemy/configuration_methods'
require_relative 'alchemy/controller_actions'
require_relative 'alchemy/deprecation'
require_relative 'alchemy/elements_finder'
require_relative 'alchemy/errors'
require_relative 'alchemy/essence'
require_relative 'alchemy/filetypes'
require_relative 'alchemy/forms/builder'
require_relative 'alchemy/hints'
require_relative 'alchemy/i18n'
require_relative 'alchemy/logger'
require_relative 'alchemy/modules'
require_relative 'alchemy/name_conversions'
require_relative 'alchemy/on_page_layout'
require_relative 'alchemy/on_page_layout/callbacks_runner'
require_relative 'alchemy/page_layout'
require_relative 'alchemy/paths'
require_relative 'alchemy/permissions'
require_relative 'alchemy/ssl_protection'
require_relative 'alchemy/resource'
require_relative 'alchemy/tinymce'
require_relative 'alchemy/taggable'

# Require hacks
require_relative 'kaminari/scoped_pagination_url_helper'

# Finally require Alchemy itself
require_relative 'alchemy/engine'
