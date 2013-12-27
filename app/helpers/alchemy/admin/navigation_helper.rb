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
        render(
          'alchemy/admin/partials/main_navigation_entry',
          alchemy_module: alchemy_module.stringify_keys,
          navigation: module_main_navigation(alchemy_module)
        )
      end

      # Renders the subnavigation from current module
      #
      # We find the module from current controller and index action.
      #
      def admin_subnavigation
        if current_alchemy_module.present?
          render(
            'alchemy/admin/partials/sub_navigation',
            entries: current_sub_navigation
          )
        end
      end

      # Used for checking the main navi permissions
      #
      # To let your module be navigatable by the user you have to provide an Ability for it.
      #
      # === Example:
      #
      #   # module.yml
      #   name: 'my_module'
      #   navigation: {
      #     controller: 'my/admin/posts'
      #     action: 'index'
      #   }
      #
      #   # ability.rb
      #   can :index, :my_admin_posts
      #
      def navigate_module(navigation)
        navigation.stringify_keys!
        [
          navigation['action'].to_sym,
          navigation['controller'].to_s.gsub(/\A\//, '').gsub(/\//, '_').to_sym
        ]
      end

      # CSS classes for main navigation entry.
      #
      def main_navigation_css_classes(navigation)
        [
          'main_navi_entry',
          admin_mainnavi_active?(navigation) ? 'active' : nil
        ].compact.join(' ')
      end

      # Returns true if given navi entry is in params controller and action
      #
      # == Example
      #   <%= entry_active?({controller: 'admin/users', action: 'index'}) %>
      #
      # @param [Hash]
      #   A Alchemy module definition navigation entry
      #
      def entry_active?(entry)
        is_entry_controller_active?(entry) && is_entry_action_active?(entry)
      end

      # Returns url for given Alchemy module.
      #
      # If the module is inside an engine it calls the +url_for+ helper on the engines routing proxy.
      #
      # If the module is inside the host rails app it calls the +url_for+ helper on the main_app routing proxy.
      #
      # @param [Hash]
      #   A Alchemy module definition
      #
      def url_for_module(alchemy_module)
        route_from_engine_or_main_app(
          alchemy_module['engine_name'],
          url_options_for_module(alchemy_module)
        )
      end

      # Returns url for given Alchemy module sub navigation entry.
      #
      # If the module is inside an engine it calls the +url_for+ helper on the engines routing proxy.
      #
      # If the module is inside the host rails app it calls the +url_for+ helper on the main_app routing proxy.
      #
      # @param [Hash]
      #   A Alchemy module sub navigation definition
      #
      def url_for_module_sub_navigation(navigation)
        alchemy_module = module_definition_for(navigation)
        return if alchemy_module.nil?
        route_from_engine_or_main_app(
          alchemy_module['engine_name'],
          url_options_for_navigation_entry(navigation)
        )
      end

      # Alchemy modules for main navigation.
      #
      # Sorted by position attribute, if given.
      #
      def sorted_alchemy_modules
        sorted = []
        not_sorted = []
        alchemy_modules.map do |m|
          if m['position'].blank?
            not_sorted << m
          else
            sorted << m
          end
        end
        sorted.sort_by { |m| m['position'] } + not_sorted
      end

      private

      # Calls +url_for+ helper on engine if present or on host app.
      #
      # @param [String]
      #   A name of an engine
      # @param [Hash]
      #   url options hash passed to +url_for+ helper
      #
      def route_from_engine_or_main_app(engine_name, url_options)
        if engine_name.present?
          eval(engine_name).url_for(url_options)
        else
          main_app.url_for(url_options)
        end
      end

      # Returns a url options hash for given Alchemy module.
      #
      # @param [Hash]
      #   A Alchemy module definition
      #
      def url_options_for_module(alchemy_module)
        url_options_for_navigation_entry(module_main_navigation(alchemy_module))
      end

      # Returns a url options hash for given navigation entry.
      #
      # @param [Hash]
      #   A Alchemy module navigation entry
      #
      def url_options_for_navigation_entry(entry)
        entry.stringify_keys!
        {
          controller: entry['controller'],
          action: entry['action'],
          only_path: true
        }
      end

      # Retrieves the current Alchemy module from controller and index action.
      #
      def current_alchemy_module
        module_definition_for(controller: params[:controller], action: 'index')
      end

      # Returns the sub navigation for current Alchemy module.
      #
      def current_sub_navigation
        module_sub_navigation(module_main_navigation(current_alchemy_module))
      end

      # Returns navigation entries from given module.
      #
      def module_main_navigation(alchemy_module)
        alchemy_module.fetch('navigation', {}).stringify_keys
      end

      # Returns sub navigation entries from given module.
      #
      def module_sub_navigation(alchemy_module)
        alchemy_module.fetch('sub_navigation', []).map(&:stringify_keys)
      end

      # Returns nested navigation entries for given module.
      #
      def module_nested_navigation(alchemy_module)
        alchemy_module.fetch('nested', []).map(&:stringify_keys)
      end

      # Returns true if the current controller and action is in a modules navigation definition.
      #
      def admin_mainnavi_active?(main_navigation)
        main_navigation.stringify_keys!
        # Has the given navigation entry a active sub navigation?
        has_active_entry?(module_sub_navigation(main_navigation)) or
          # Has the given navigation entry a active nested navigation?
          has_active_entry?(module_nested_navigation(main_navigation)) or
            # Is the navigation entry active?
            entry_active?(main_navigation)
      end

      # Returns true if the given entry's controller is current controller
      #
      def is_entry_controller_active?(entry)
        entry['controller'].gsub(/\A\//, '') == params[:controller]
      end

      # Returns true if the given entry's action is current controllers action
      #
      # Also checks if given entry has a +nested_actions+ key, if so it checks if one of them is current controller's action
      #
      def is_entry_action_active?(entry)
        entry['action'] == params[:action] || entry['nested_actions'].to_a.include?(params[:action])
      end

      # Returns true if an entry of given entries is active.
      #
      # @param [Array]
      #   Alchemy module navigation entries.
      #
      def has_active_entry?(entries)
        !entries.detect { |entry| entry_active?(entry) }.nil?
      end

    end
  end
end
