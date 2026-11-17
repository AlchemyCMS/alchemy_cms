# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Number ingredient admin feature", type: :system do
  let(:a_page) { create(:alchemy_page) }
  let!(:element) do
    create(:alchemy_element, :with_ingredients, name: "all_you_can_eat", page_version: a_page.draft_version)
  end

  before do
    authorize_user(:as_editor)
    allow_any_instance_of(Alchemy::Ingredients::Number).to receive(:settings) do
      {input_type: "range", min: 0, max: 10, step: 1}
    end
  end

  scenario "the value next to a range input follows the slider", :js do
    visit alchemy.admin_elements_path(page_version_id: a_page.draft_version.id)

    within ".ingredient-editor.number" do
      range = find("input[type='range']")
      range.set(3)
      expect(page).to have_css("output", exact_text: "3")
    end
  end
end
