module Alchemy
  module Admin
    # This component is used to display the name of the current Alchemy user in the admin interface.
    class CurrentUserName < ViewComponent::Base
      def initialize(user:)
        @user = user
        @display_name = user.try(:alchemy_display_name)
      end

      def call
        tag.span class: "current-user-name" do
          safe_join [
            '<alchemy-icon name="user" size="1x"></alchemy-icon>'.html_safe,
            link_to_if(edit_user_path, display_name, edit_user_path)
          ]
        end
      end

      def render?
        user && display_name.present?
      end

      private

      attr_reader :user, :display_name

      def edit_user_path
        return unless Alchemy.config.edit_user_path

        Alchemy.config.edit_user_path.gsub(":id", user.id.to_s)
      end
    end
  end
end
