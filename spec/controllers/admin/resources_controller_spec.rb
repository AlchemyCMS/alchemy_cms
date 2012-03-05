require_relative "../../../lib/alchemy/resource"
require_relative "../../../lib/alchemy/resource_helper"

module Alchemy
	module Admin
		class ResourcesController
			helper Alchemy::ResourceHelper
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