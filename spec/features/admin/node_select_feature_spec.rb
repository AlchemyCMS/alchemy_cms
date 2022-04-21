# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Node select", type: :system, js: true do
  before do
    authorize_user(:as_admin)
  end

  let(:english_element) { create(:alchemy_element, name: :menu, page: create(:alchemy_page)) }
  let!(:english_node) { create(:alchemy_node, name: "test") }

  let!(:klingon) { create(:alchemy_language, :klingon) }
  let(:klingon_element) { create(:alchemy_element, name: :menu, page: create(:alchemy_page, language: klingon)) }
  let!(:klingon_node) { create(:alchemy_node, name: "test", language: klingon) }

  %w(english klingon).each do |language|
    context language do
      let(:element) { send "#{language}_element" }
      let(:node) { send "#{language}_node" }

      it "restricts to the site/language of the page the element is on" do
        visit alchemy.admin_elements_path(page_version_id: element.page_version_id)
        select2_search("test", element_id: element.id, content_name: "menu")
        within "#element_#{element.id}" do
          click_on("Save")
        end

        expect(page).to have_content("Saved", wait: 5)
        expect(element.reload.ingredient(:menu)).to eq(node)
      end
    end
  end
end
