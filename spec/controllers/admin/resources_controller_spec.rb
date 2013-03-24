require "spec_helper"

describe Alchemy::Admin::ResourcesController do
  describe "index" do
    it "should include ResourcesHelper" do
      Alchemy::Admin::ResourcesController.new.respond_to?(:resource_window_size).should be_true
    end
  end
end