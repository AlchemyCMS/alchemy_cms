# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Tags", type: :system do
  let!(:picture) { create(:alchemy_picture, tag_list: "Foo") }
  let!(:picture2) { create(:alchemy_picture, tag_list: "Foo") }
  let!(:a_page) { create(:alchemy_page, tag_list: "Bar") }

  before { authorize_user(:as_admin) }

  describe "index view" do
    it "should list taggable class names" do
      visit "/admin/tags"
      expect(page).to have_selector(".label", text: "Picture", count: 1)
      expect(page).to have_selector(".label", text: "Page", count: 1)
    end
  end
end
