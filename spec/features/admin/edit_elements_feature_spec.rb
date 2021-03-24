# frozen_string_literal: true

require "rails_helper"

RSpec.describe "The edit elements feature", type: :system do
  let!(:a_page) { create(:alchemy_page) }

  before do
    authorize_user(:as_editor)
  end

  context "Visiting the new element form" do
    context "with a page_version_id passed" do
      scenario "a form to select a new element for the page appears." do
        visit alchemy.new_admin_element_path(page_version_id: a_page.draft_version.id)
        expect(page).to have_selector('select[name="element[name]"]')
      end
    end

    context "with a page_version_id and parent_element_id passed" do
      let!(:element) do
        create(:alchemy_element, :with_nestable_elements, page_version: a_page.draft_version)
      end

      scenario "a hidden field with parent element id is in the form." do
        visit alchemy.new_admin_element_path(page_version_id: a_page.draft_version.id, parent_element_id: element.id)
        expect(page).to have_selector(%(input[type="hidden"][name="element[parent_element_id]"][value="#{element.id}"]))
      end
    end

    context "with element in clipboard" do
      let(:element) do
        create(:alchemy_element, page_version: a_page.draft_version)
      end

      before do
        expect_any_instance_of(Alchemy::Admin::ElementsController).to receive(:get_clipboard) do
          [
            { "id" => element.id, "action" => "copy" },
          ]
        end
      end

      scenario "a hidden field with page version id is in the form." do
        visit alchemy.new_admin_element_path(page_version_id: a_page.draft_version.id)
        expect(page).to have_selector(%(input[type="hidden"][name="element[page_version_id]"][value="#{a_page.draft_version.id}"]))
      end
    end
  end

  context "With an element having one nestable element defined" do
    let!(:element) do
      create(:alchemy_element, :with_nestable_elements, page_version: a_page.draft_version)
    end

    scenario "the add element button immediately creates the nested element.", :js do
      visit alchemy.admin_elements_path(page_version_id: element.page_version_id)
      button = page.find(".add-nestable-element-button")
      expect(button).to have_content "Add slide"
      button.click
      expect(page).to have_selector(".element-editor[data-element-name='slide']")
    end
  end

  context "With an element having multiple nestable element defined" do
    let!(:element) do
      create(:alchemy_element,
             :with_nestable_elements,
             name: :right_column,
             page_version: a_page.draft_version)
    end

    scenario "the add element button opens add element form.", :js do
      visit alchemy.admin_elements_path(page_version_id: element.page_version_id)
      button = page.find(".add-nestable-element-button")
      expect(button).to have_content "New element"
      button.click
      expect(page).to have_select("Element")
      within ".alchemy-dialog" do
        select2("Text", from: "Element")
        click_button("Add")
      end
      expect(page).to have_selector(".element-editor[data-element-name='text']")
    end
  end

  describe "Copy element", :js do
    let!(:element) { create(:alchemy_element, page: a_page) }

    scenario "is possible to copy element into clipboard" do
      visit alchemy.admin_elements_path(page_version_id: element.page_version_id)
      expect(page).to have_selector(".element-toolbar")
      find(".fa-clone").click
      within "#flash_notices" do
        expect(page).to have_content(/Copied Article/)
      end
    end
  end
end
