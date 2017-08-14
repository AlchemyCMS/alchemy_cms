# frozen_string_literal: true

module Alchemy
  module Modules
    mattr_accessor :alchemy_modules

    @@alchemy_modules = YAML.load_file(File.expand_path('../../../config/alchemy/modules.yml', __FILE__))

    def self.included(base)
      base.send :helper_method, :alchemy_modules, :module_definition_for
    end

    # Register a Alchemy module.
    #
    # A module is a Hash that must have at least a name and a navigation key
    # that has a controller and action name.
    #
    # == Example:
    #
    #     name: 'module',
    #     navigation: {
    #       controller: 'admin/controller_name',
    #       action: 'index'
    #     }
    #
    def self.register_module(module_definition)
      @@alchemy_modules << module_definition.deep_stringify_keys
    end

    # Get the module definition for given module name
    #
    # You can also pass a hash of an module definition.
    # It then tries to find the module defintion from controller name and action name
    #
    def module_definition_for(name_or_params)
      case name_or_params
      when String
        alchemy_modules.detect { |m| m['name'] == name_or_params }
      when Hash
        name_or_params.stringify_keys!
        alchemy_modules.detect do |alchemy_module|
          module_navi = alchemy_module.fetch('navigation', {})
          definition_from_mainnavi(module_navi, name_or_params) ||
            definition_from_subnavi(module_navi, name_or_params)
        end
      else
        raise ArgumentError, "Could not find module definition for #{name_or_params}"
      end
    end

    private

    def definition_from_mainnavi(module_navi, params)
      controller_matches?(module_navi, params) && action_matches?(module_navi, params)
    end

    def definition_from_subnavi(module_navi, params)
      subnavi = module_navi['sub_navigation']
      return if subnavi.nil?

      subnavi.any? do |navi|
        controller_matches?(navi, params) && action_matches?(navi, params)
      end
    end

    def controller_matches?(navi, params)
      remove_slash(navi['controller']) == remove_slash(params['controller'])
    end

    def action_matches?(navi, params)
      navi['action'] == params['action']
    end

    def remove_slash(str)
      str.gsub(/^\//, '')
    end
  end
end
