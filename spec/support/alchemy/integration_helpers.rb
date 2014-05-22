require 'declarative_authorization/maintenance'

module Alchemy
  module Specs

    # Helpers for integration specs
    #
    # This file is included in rspec integration/request tests.
    #
    module IntegrationHelpers
      include ::Authorization::TestHelper

      # Shortcut method for:
      #
      #   * create_admin_user
      #   * login_into_alchemy
      #
      def authorize_as_admin
        create_admin_user
        login_into_alchemy
      end

      # Capybara actions to login into Alchemy Backend
      #
      # You should have a admin user before loggin in.
      #
      # See: create_admin_user method
      #
      def login_into_alchemy
        # Ensure that phantomjs has always the same browser language.
        if Capybara.current_driver == :poltergeist
          page.driver.headers = { 'Accept-Language' => 'en' }
        end
        visit login_path
        fill_in('user_login', :with => 'jdoe')
        fill_in('user_password', :with => 's3cr3t')
        click_on('Login')
      end

      # Load additional authorization_rules for specs.
      #
      # For some strange reason, this isn't done automatically while running the specs
      #
      def load_authorization_rules
        instance = Alchemy::Auth::Engine.get_instance
        instance.load(File.join(File.dirname(__FILE__), '../../dummy', 'config/authorization_rules.rb'))
      end

      # Creates an admin user in a way it works
      #
      # You should create it once in a before block
      #
      # === Example:
      #
      #   before do
      #     create_admin_user
      #   end
      #
      def create_admin_user
        FactoryGirl.create(:admin_user)
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
