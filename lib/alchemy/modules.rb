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
        Alchemy.config.menu.map { |menu_item| to_legacy_hash(menu_item) }
      end
      deprecate alchemy_modules: "Use `Alchemy.config.menu` instead", deprecator: Alchemy::Deprecation

      def to_legacy_hash(menu_item)
        {
          "name" => menu_item.name,
          "engine_name" => menu_item.engine_name,
          "position" => menu_item.position,
          "navigation" => to_legacy_navigation(menu_item)
        }.compact
      end

      private

      def to_legacy_navigation(menu_item)
        {
          "name" => menu_item.title,
          "controller" => menu_item.controller,
          "action" => menu_item.action,
          "url" => menu_item.url,
          "condition" => menu_item.condition,
          "icon" => menu_item.icon,
          "icon-style" => menu_item.icon_style,
          "image" => menu_item.image,
          "inline_image" => menu_item.inline_image,
          "data" => menu_item.turbo ? nil : {turbo: false},
          "nested_controllers" => menu_item.nested_controllers.to_a.presence,
          "nested_actions" => menu_item.nested_actions.to_a.presence,
          "sub_navigation" => menu_item.children.map { |child| to_legacy_navigation(child) }.presence,
          "nested" => menu_item.nested.map { |entry| to_legacy_navigation(entry) }.presence
        }.compact
      end
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
      Alchemy::Modules.to_legacy_hash(menu_item) if menu_item
    end
    deprecate module_definition_for: "Use `Alchemy.config.menu` instead", deprecator: Alchemy::Deprecation
  end
end
