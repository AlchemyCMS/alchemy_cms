module Alchemy
  module TestSupport

    # Helpers for integration specs
    #
    # This file is included in rspec integration/request tests.
    #
    module IntegrationHelpers

      # Used in Capybara features specs. Stubs the current_alchemy_user
      #
      # It mocks an admin user, but you can pass in a user object that would be used as stub.
      #
      def authorize_as_admin(user=nil)
        # Ensure that phantomjs has always the same browser language.
        if Capybara.current_driver == :poltergeist
          page.driver.headers = { 'Accept-Language' => 'en' }
        end
        if !user
          user = mock_model('DummyUser', alchemy_roles: %w(admin), language: 'en')
        end
        ApplicationController.any_instance.stub(:current_user).and_return(user)
      end
    end

  end
end
