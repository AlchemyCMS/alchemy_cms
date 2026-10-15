# frozen_string_literal: true

module Alchemy
  module Modules
    class << self
      def included(base)
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
      def register_module(module_definition)
        menu_item = Alchemy::Configurations::MenuItem.from_legacy_hash(module_definition)
        return if menu_item.name.present? && Alchemy.config.menu.any? { |item| item.name == menu_item.name }

        Alchemy.config.menu.add(menu_item)
      end
      deprecate register_module: "Use `Alchemy.config.menu.add` instead", deprecator: Alchemy::Deprecation

      def alchemy_modules
        Alchemy.config.menu.map(&:to_legacy_hash)
      end
      deprecate alchemy_modules: "Use `Alchemy.config.menu` instead", deprecator: Alchemy::Deprecation
    end

    def alchemy_modules
      Alchemy::Modules.alchemy_modules
    end

    # Get the module definition for given module name
    #
    # You can also pass a hash of an module definition.
    # It then tries to find the module defintion from controller name and action name
    #
    def module_definition_for(name_or_params)
      menu_item = case name_or_params
      when String
        Alchemy.config.menu.detect { |item| item.name == name_or_params }
      when Hash
        params = name_or_params.stringify_keys
        Alchemy.config.menu.detect do |item|
          [item, *item.children, *item.nested].any? do |entry|
            entry.matches_controller?(controller: params["controller"], action: params["action"])
          end
        end
      else
        raise ArgumentError, "Could not find module definition for #{name_or_params}"
      end
      menu_item&.to_legacy_hash
    end
    deprecate module_definition_for: "Use `Alchemy.config.menu` instead", deprecator: Alchemy::Deprecation
  end
end
