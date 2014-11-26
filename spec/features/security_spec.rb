require 'spec_helper'

describe "Security." do
  before { Alchemy::Page.root.children.destroy_all }

  context "If user is not logged in" do
    it "should see login form" do
      visit '/admin/dashboard'
      expect(current_path).to eq(Alchemy.login_path)
    end
  end
end
