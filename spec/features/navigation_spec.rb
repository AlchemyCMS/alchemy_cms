# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Dummy App", type: :system do
  include Capybara::DSL

  it "should be a valid app" do
    expect(::Rails.application).to be_a(Dummy::Application)
  end
end
