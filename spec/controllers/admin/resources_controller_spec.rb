require "spec_helper"

module Alchemy
  describe Admin::ResourcesController do
    it "should include ResourcesHelper" do
      controller.respond_to?(:resource_window_size).should be_true
    end
  end
end
