require 'declarative_authorization/maintenance'

module Alchemy
  module Specs
    # Helpers for integration specs
    # This file is auto included in rspec integration/request tests.
    module Helpers
      include Authorization::TestHelper

      # Capybara actions to login into Alchemy Backend
      #
      # === IMPORTANT NOTE:
      #
      # Because of a very strange bug in capybara, or rspec, or what ever, you **MUST** create the user inside a +before(:all)+ block inside your integrations specs.
      #
      # === Example:
      #
      #   before(:all) do
      #     create_admin_user
      #   end
      #
      def login_into_alchemy
        visit '/alchemy/admin/login'
        fill_in('alchemy_user_session_login', :with => 'jdoe')
        fill_in('alchemy_user_session_password', :with => 's3cr3t')
        click_on('Login')
      end

      # Load additional authorization_rules for specs.
      # For some strange reason, this isn't done automatically while running the specs
      def load_authorization_rules
        instance = Alchemy::AuthEngine.get_instance
        instance.load(File.join(File.dirname(__FILE__), '../../dummy', 'config/authorization_rules.rb'))
      end

      # Creates an admin user in a way it works
      def create_admin_user
        @user = FactoryGirl.build(:admin_user).save_without_session_maintenance
      end

    end
  end
end

RSpec.configure do |c|
  c.include Alchemy::Specs::Helpers, :type => :request
end
