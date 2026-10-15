# frozen_string_literal: true

module Alchemy
  module Admin
    # This module contains helper methods for rendering the admin navigation.
    #
    module NavigationHelper
      # Renders one admin main navigation entry
      #
      # @param [Hash] alchemy_module
      #   The Hash representing a Alchemy module
      #
      def alchemy_main_navigation_entry(alchemy_module)
        render Alchemy::Admin::MainNavigation::Entry.new(
          item: Alchemy::Configurations::MenuItem.from_legacy_hash(alchemy_module)
        )
      end
      deprecate alchemy_main_navigation_entry: "Render `Alchemy::Admin::MainNavigation::Entry` instead",
        deprecator: Alchemy::Deprecation

      # Returns url for given Alchemy module.
      #
      # @param [Hash]
      #   A Alchemy module definition
      #
      def url_for_module(alchemy_module)
        Alchemy::Configurations::MenuItem.from_legacy_hash(alchemy_module).path(self)
      end
      deprecate url_for_module: "Use `Alchemy::Configurations::MenuItem#path` instead",
        deprecator: Alchemy::Deprecation

      # Alchemy modules for main navigation.
      #
      # Sorted by position attribute, if given.
      #
      def sorted_alchemy_modules
        Alchemy::Admin::MainNavigation::Menu.new.items.map(&:to_legacy_hash)
      end
      deprecate sorted_alchemy_modules: "Use `Alchemy.config.menu` instead",
        deprecator: Alchemy::Deprecation

      private

      # Retrieves the current Alchemy module from controller and index action.
      #
      def current_alchemy_module
        module_definition_for(controller: params[:controller], action: "index")
      end
    end
  end
end
