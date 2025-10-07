# frozen_string_literal: true

require "rails_helper"

RSpec.describe "layouts/alchemy/admin.html.erb" do
  before do
    view.extend Alchemy::Admin::BaseHelper
    allow(view).to receive(:alchemy_modules).and_return([])
    allow(view).to receive(:current_alchemy_user).and_return(DummyUser.new)
    allow(view).to receive(:configuration).and_return({})
  end

  subject do
    render template: "layouts/alchemy/admin"
    rendered
  end

  context "with Alchemy.config.admin_js_imports" do
    around do |example|
      current = Alchemy.config.admin_js_imports
      Alchemy.config.admin_js_imports << "foo"
      example.run
      Alchemy.config.admin_js_imports = current
    end

    it "renders the given javascripts module imports" do
      expect(subject).to have_selector("script[type=\"module\"]:last-of-type", text: /import "foo"/)
    end
  end

  context "without Alchemy.config.admin_js_imports" do
    it "does not render the given javascripts module imports" do
      expect(subject).to_not have_selector("script[type=\"module\"]:last-of-type", text: /import "foo"/)
    end
  end
end
