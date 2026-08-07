# frozen_string_literal: true

module Alchemy
  class Upgrader
    module EightFour
      # Alchemy does not depend on the dragonfly gem anymore.
      # Apps still using the dragonfly storage adapter need to
      # declare the gem in their own Gemfile.
      def add_dragonfly_gem
        return unless Alchemy.storage_adapter.dragonfly?

        run %(bundle add dragonfly --version "~> 1.4")
      end

      # Menus now hide nodes whose page a user may not read. The generated menu
      # partials live in the host app, so Alchemy cannot update them here.
      def mention_menu_partials_readable_children
        todo(<<~TODO.strip, "Update your menu partials for restricted pages")
          Alchemy now hides menu nodes whose page a user is not allowed to read
          (restricted pages and pages limited to certain roles).

          The generated menu partials in `app/views/alchemy/menus/*/` were changed
          to render `node.readable_children(current_alchemy_user)` instead of
          `node.children`, and to include the current user in their `cache` key so
          a filtered menu is not served to a different user.

          Please apply the same change to your menu partials (or regenerate them
          with `bin/rails g alchemy:menus`), otherwise restricted pages keep
          leaking their name and url through your navigation.
        TODO
      end
    end
  end
end
