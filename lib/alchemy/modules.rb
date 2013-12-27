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
      @@alchemy_modules << module_definition.stringify_keys
    end

    # Get the module definition for given module name
    #
    # You can also pass a hash of an module definition.
    # It then tries to find the module defintion from controller name and action name
    #
    def module_definition_for(name)
      case name
      when String
        alchemy_modules.detect { |p| p['name'] == name }
      when Hash
        alchemy_modules.detect do |alchemy_module|
          definition_from_subnavi(alchemy_module, name.symbolize_keys)
        end
      else
        raise "Could not find module definition for #{name}"
      end
    end

    private

    def alchemy_module_navigation(alchemy_module)
      alchemy_module.stringify_keys!
      alchemy_module.fetch('navigation', {}).stringify_keys
    end

    def definition_from_subnavi(alchemy_module, name)
      module_navi = alchemy_module_navigation(alchemy_module)
      subnavi = module_navi['sub_navigation']
      return if subnavi.nil?
      subnavi.map(&:stringify_keys).detect do |subnavi|
        controller_matches?(subnavi, name) && action_matches?(subnavi, name)
      end
    end

    def controller_matches?(subnavi, name)
      remove_slash(subnavi['controller']) == remove_slash(name[:controller])
    end

    def action_matches?(subnavi, name)
      subnavi['action'] == name[:action]
    end

    def remove_slash(name)
      name.gsub(/^\//, '')
    end

  end
end
