require_relative "../../../lib/alchemy/resource"
require_relative "../../../lib/alchemy/resources_helper"

module Alchemy
	module Admin
		class ResourcesController
			helper Alchemy::ResourcesHelper
		end
	end
end


describe Alchemy::Admin::ResourcesController do
	describe "index" do
		it "should include ResourcesHelper" do
			Alchemy::Admin::ResourcesController.new.respond_to?(:resource_window_size).should be_true
		end
	end
end