# *There is generally no need* to use this module. Instead, in
# a functional/controller test against a Alchemy controller, just
# use standard Rails functionality by including:
#
#   routes { Alchemy::Engine.routes }
#
# And then use standard Rails test `get`, `post` etc methods.
#
# Use this module to easily test Alchemy actions within Alchemy components
# or inside your application to test routes for the mounted Alchemy engine.
#
# Inside your spec_helper.rb, include this module inside the RSpec.configure
# block by doing this:
#
#   require 'alchemy/test_support/controller_requests'
#   RSpec.configure do |c|
#     c.include Alchemy::TestSupport::ControllerRequests, type: :controller
#   end
#
# Then, in your controller tests, you can access alchemy routes like this:
#
#   require 'spec_helper'
#
#   describe Alchemy::Admin::PagesController do
#     it "can see all the pages" do
#       alchemy_get :index
#     end
#   end
#
# Use alchemy_get, alchemy_post, alchemy_put or alchemy_delete to make requests
# to the Alchemy engine, and use regular get, post, put or delete to make
# requests to your application.
#
# Note: Based on Spree::TestingSupport::ControllerRequests. Thanks <3
#
# @deprecated Use Rails build in test request methods instead
#
module Alchemy
  module TestSupport
    module ControllerRequests
      extend ActiveSupport::Concern

      # Executes a request simulating GET HTTP method
      # @deprecated Use Rails test `get` helper instead
      def alchemy_get(action, parameters = nil, session = nil, flash = nil)
        process_alchemy_action(action, parameters, session, flash, "GET")
      end
      deprecate alchemy_get: :get, deprecator: Alchemy::Deprecation

      # Executes a request simulating POST HTTP method
      # @deprecated Use Rails test `post` helper instead
      def alchemy_post(action, parameters = nil, session = nil, flash = nil)
        process_alchemy_action(action, parameters, session, flash, "POST")
      end
      deprecate alchemy_post: :post, deprecator: Alchemy::Deprecation

      # Executes a request simulating PUT HTTP method
      # @deprecated Use Rails test `put` helper instead
      def alchemy_put(action, parameters = nil, session = nil, flash = nil)
        process_alchemy_action(action, parameters, session, flash, "PUT")
      end
      deprecate alchemy_put: :put, deprecator: Alchemy::Deprecation

      # Executes a request simulating DELETE HTTP method
      # @deprecated Use Rails test `delete` helper instead
      def alchemy_delete(action, parameters = nil, session = nil, flash = nil)
        process_alchemy_action(action, parameters, session, flash, "DELETE")
      end
      deprecate alchemy_delete: :delete, deprecator: Alchemy::Deprecation

      # Executes a simulated XHR request
      # @deprecated Use Rails test `xhr` helper instead
      def alchemy_xhr(method, action, parameters = nil, session = nil, flash = nil)
        process_alchemy_xhr_action(method, action, parameters, session, flash)
      end
      deprecate alchemy_xhr: :xhr, deprecator: Alchemy::Deprecation

      private

      def process_alchemy_action(action, parameters = nil, session = nil, flash = nil, method = "GET")
        @routes = Alchemy::Engine.routes
        parameters ||= {}
        process(action, method, parameters, session, flash)
      end

      def process_alchemy_xhr_action(method, action, parameters = nil, session = nil, flash = nil)
        @routes = Alchemy::Engine.routes
        parameters ||= {}
        xml_http_request(method, action, parameters, session, flash)
      end
    end
  end
end
