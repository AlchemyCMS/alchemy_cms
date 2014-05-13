require 'declarative_authorization/maintenance'

module Alchemy
  module TestSupport

    # Helpers for integration specs
    #
    # This file is included in rspec integration/request tests.
    #
    module IntegrationHelpers
      include ::Authorization::TestHelper

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
          user = mock_model('DummyUser', alchemy_roles: %w(admin), role_symbols: [:admin], language: 'en')
        end
        ApplicationController.any_instance.stub(:current_user).and_return(user)
      end

      # Load additional authorization_rules for specs.
      #
      # For some strange reason, this isn't done automatically while running the specs
      #
      def load_authorization_rules
        instance = Alchemy::Auth::Engine.get_instance
        instance.load(File.join(File.dirname(__FILE__), '../../../spec/dummy', 'config/authorization_rules.rb'))
      end

      # Capybara actions to create a new element.
      #
      # You can pass the name of the desired element, or just use the default "Article".
      #
      def create_element!(name = 'Article')
        within '.alchemy-elements-window' do
          click_link Alchemy::I18n.t('New Element')
        end
        within '.new_alchemy_element' do
          select(name, from: 'element[name]')
          click_button 'Add'
        end
      end
    end

  end
end
