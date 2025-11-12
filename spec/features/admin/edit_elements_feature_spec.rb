# frozen_string_literal: true

require "rails_helper"

RSpec.describe "The edit elements feature", type: :system do
  let!(:a_page) { create(:alchemy_page) }

  before do
    authorize_user(:as_editor)
  end

  context "The elements window" do
    it "shows a clipboard button" do
      visit alchemy.admin_elements_path(page_version_id: a_page.draft_version.id)
      expect(page).to have_selector("#clipboard_button")
    end
  end

  context "Visiting the new element form" do
    context "with a page_version_id passed" do
      scenario "a form to select a new element for the page appears." do
        visit alchemy.new_admin_element_path(page_version_id: a_page.draft_version.id)
        expect(page).to have_selector('alchemy-element-select input[name="element[name]"]')
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
            {"id" => element.id, "action" => "copy"}
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

    context "when clipboard has a nestable element" do
      before do
        allow_any_instance_of(Alchemy::Admin::ElementsController).to receive(:get_clipboard) do
          [
            {
              "id" => create(:alchemy_element, name: element.definition.nestable_elements.first).id,
              "action" => "copy"
            }
          ]
        end
      end

      scenario "the add button opens add element form with the clipboard tab", :js do
        visit alchemy.admin_elements_path(page_version_id: element.page_version_id)
        button = page.find(".add-nestable-element-button")
        expect(button).to have_content "Add Slide"
        button.click

        expect(page).to have_css(".alchemy-dialog")
        within ".alchemy-dialog" do
          expect(page).to have_select("Element")
          expect(page).to have_css("[panel='paste_element_tab']")
        end
      end
    end

    context "when clipboard does not have a nestable element", :js do
      scenario "the add element button immediately creates the nested element." do
        visit alchemy.admin_elements_path(page_version_id: element.page_version_id)
        button = page.find("button.add-nestable-element-button")
        expect(button).to have_content "Add Slide"
        button.click
        expect(page).to have_selector(".element-editor[data-element-name='slide']")
      end

      context "when a nested element is copied to clipboard" do
        before do
          visit alchemy.edit_admin_page_path(element.page)
          page.find(".add-nestable-element-button").click
          new_element = Alchemy::Element.last
          page.find("#element_#{new_element.id} .element-header").hover
          page.first("form[action^='/admin/clipboard/insert?remarkable_id=#{new_element.id}&remarkable_type=elements'] button").click
          expect(page).to have_content("Copied Slide: to clipboard")
        end

        scenario "the add button now opens add element form with the clipboard tab" do
          find("a.add-nestable-element-button").click
          expect(page).to have_css(".alchemy-dialog")
          within ".alchemy-dialog" do
            expect(page).to have_select("Element")
            expect(page).to have_css("[panel='paste_element_tab']")
          end
        end
      end
    end
  end

  context "With an element having multiple nestable elements defined" do
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
      expect(page).to have_css(".alchemy-dialog")
      within ".alchemy-dialog" do
        expect(page).to have_field("Element")
        select2("Text", from: "Element")
        click_button("Add")
      end
      expect(page).to have_selector(".element-editor[data-element-name='text']")
    end
  end

  describe "Copy element", :js do
    let!(:element) { create(:alchemy_element, page_version: a_page.draft_version) }

    scenario "is possible to copy element into clipboard" do
      visit alchemy.admin_elements_path(page_version_id: element.page_version_id)
      expect(page).to have_selector(".element-toolbar")
      click_icon("file-copy")
      within "#flash_notices" do
        expect(page).to have_content(/Copied Article/)
      end
    end
  end

  describe "Updating an element", :js do
    context "with valid data" do
      let!(:element) { create(:alchemy_element, page_version: a_page.draft_version) }

      scenario "shows success notice" do
        visit alchemy.admin_elements_path(page_version_id: element.page_version_id)
        expect(page).to have_button("Save")
        click_button("Save")
        within "#flash_notices" do
          expect(page).to have_content(/Saved element/)
        end
      end
    end

    context "with invalid data" do
      let!(:element) { create(:alchemy_element, name: "all_you_can_eat", page_version: a_page.draft_version) }

      scenario "shows error notice" do
        visit alchemy.admin_elements_path(page_version_id: element.page_version_id)
        fill_in "Headline", with: "123"
        expect(page).to have_button("Save")
        click_button("Save")
        within "#flash_notices" do
          expect(page).to have_content(/Validation failed/)
        end
        within ".element_errors" do
          expect(page).to have_content(/Please check marked fields below/)
        end
      end
    end
  end

  describe "With an element that has ingredient groups" do
    let(:element) do
      create(
        :alchemy_element,
        :with_ingredients,
        page_version: a_page.draft_version,
        name: "element_with_ingredient_groups"
      )
    end

    # Need to be on page editor rather than just admin_elements in order to have JS interaction
    before { visit alchemy.edit_admin_page_path(element.page) }

    scenario "expanded ingredient groups persist between visits", :js do
      page.find("details#element_#{element.id}_ingredient_group_details", text: "Details").click
      expect(page).to have_selector("#element_#{element.id}_ingredient_group_details", visible: true)
      visit alchemy.edit_admin_page_path(element.page)
      expect(page).to have_selector("#element_#{element.id}_ingredient_group_details", visible: true)
    end
  end
end
