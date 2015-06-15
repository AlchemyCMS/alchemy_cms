module Alchemy
  module TestSupport

    # Helpers for integration specs
    #
    # This file is included in spec_helper.rb
    #
    module IntegrationHelpers

      # Used to stub the current_alchemy_user
      #
      # Pass either a user object or a symbol in the format of ':as_admin'.
      # The browser language is set to english ('en')
      #
      def authorize_user(user_or_role = nil)
        if user_or_role.is_a?(Alchemy.user_class)
          user = user_or_role
        else
          user = build(:alchemy_dummy_user, user_or_role)
        end
        set_phantomjs_browser_language("en")
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
      end

      def set_phantomjs_browser_language(lang = nil)
        if Capybara.current_driver == :poltergeist
          page.driver.headers = {"Accept-Language" => lang}
        end
      end
    end

  end
end
