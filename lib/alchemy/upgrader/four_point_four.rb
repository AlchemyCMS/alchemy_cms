# frozen_string_literal: true

require_relative 'tasks/element_views_updater'

module Alchemy
  class Upgrader::FourPointFour < Upgrader
    class << self
      def rename_element_views
        desc "Remove '_view' suffix from element views."
        Alchemy::Upgrader::Tasks::ElementViewsUpdater.new.rename_element_views
      end

      def update_local_variable
        desc 'Update element views local variable to element name.'
        Alchemy::Upgrader::Tasks::ElementViewsUpdater.new.update_local_variable
      end

      def alchemy_4_4_todos
        notice = <<-NOTE.strip_heredoc

          ℹ️  Element editor partials are deprecated
          -----------------------------------------

          The element editor partials are not needed anymore. They still work, but in order to
          prepare the Alchemy 5 upgrade your should consider removing them now.

          In order to update check if you have any messages in your editor partials and move them
          to either a `warning` or `message` in your element definition.

          Also check if you pass any values to EssenceSelects `select_values`. Move static values
          to the `settings` of your content definition and either use EssencePage for referencing
          pages or create a custom essence for other dynamic values.


          ℹ️  The `_view` suffix of Element view partials is deprecated
          -----------------------------------------------------------

          The element view partials do not need the `_view` suffix anymore. Your files have been
          renamed.

          The local variable in your element views has been replaced by a variable named after the
          element itself. A "article" element has a "_article.html.erb" partial and therefore
          a `article` local variable now.

          The former `element` variable is still present, though.

        NOTE
        todo notice, 'Alchemy v4.4 TODO'
      end
    end
  end
end
