# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin styleguide" do
  before { authorize_user(:as_admin) }

  # The page demos messages of its own, so only the flash notices count.
  def growls
    Capybara.string(response.body).all("#flash_notices alchemy-message", visible: :all)
  end

  it "renders" do
    get alchemy.admin_styleguide_path
    expect(response).to be_successful
    expect(growls).to be_empty
  end

  describe "the growl demo" do
    it "flashes the message of the requested type" do
      get alchemy.admin_styleguide_path(growl: "warn")
      expect(growls.map { [_1[:type], _1.text.strip] }).to eq([["warn", "Warning message"]])
    end

    it "ignores a type it does not know" do
      get alchemy.admin_styleguide_path(growl: "<script>alert(1)</script>")
      expect(growls).to be_empty
    end
  end
end
