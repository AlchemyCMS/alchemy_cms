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

    context "when clipboard has a nestable element" do
      before do
        allow_any_instance_of(Alchemy::Admin::ElementsController).to receive(:get_clipboard) do
          [
            { "id" => create(:alchemy_element, name: element.definition["nestable_elements"].first).id, "action" => "copy" },
          ]
        end
      end

      scenario "the add button opens add element form with the clipboard tab" do
        visit alchemy.admin_elements_path(page_version_id: element.page_version_id)
        button = page.find(".add-nestable-element-button")
        expect(button).to have_content "Add slide"
        button.click
        expect(page).to have_select("Element")
        expect(page).to have_link("Paste from clipboard")
      end
    end

    context "when clipboard does not have a nestable element", :js do
      scenario "the add element button immediately creates the nested element." do
        visit alchemy.admin_elements_path(page_version_id: element.page_version_id)
        button = page.find("button.add-nestable-element-button")
        expect(button).to have_content "Add slide"
        button.click
        expect(page).to have_selector(".element-editor[data-element-name='slide']")
      end

      context "when a nested element is copied to clipboard" do
        before do
          visit alchemy.edit_admin_page_path(element.page)
          page.find(".add-nestable-element-button").click
          new_element = Alchemy::Element.last
          page.find("#element_#{new_element.id} .element-header").hover
          page.first("a[href^='/admin/clipboard/insert?remarkable_id=#{new_element.id}&remarkable_type=elements']").click
        end

        scenario "the add button now opens add element form with the clipboard tab" do
          find("a.add-nestable-element-button").click
          expect(page).to have_select("Element")
          expect(page).to have_link("Paste from clipboard")
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

  {content: "name", ingredient: "role"}.each do |type, name_field|
    describe "With an element that has #{type} groups" do
      let(:element) { create(:alchemy_element, page: a_page, name: "element_with_#{type}_groups") }

      # Need to be on page editor rather than just admin_elements in order to have JS interaction
      before { visit alchemy.edit_admin_page_path(element.page) }

      scenario "collapsed #{type} groups shown", :js do
        # No group content initially visible
        expect(page).not_to have_selector(".content-group-contents", visible: true)

        page.find("a#element_#{element.id}_content_group_details_header", text: "Details").click
        # 'Details' group content visible
        expect(page).to have_selector("#element_#{element.id}_content_group_details", visible: true)
        within("#element_#{element.id}_content_group_details") do
          expect(page).to have_selector("[data-#{type}-#{name_field}='description']")
          expect(page).to have_selector("[data-#{type}-#{name_field}='key_words']")
        end
        expect(page).to have_selector("#element_#{element.id}_content_group_details", visible: true)

        # 'Size' group content not visible
        expect(page).not_to have_selector("#element_#{element.id}_content_group_size", visible: true)

        page.find("a#element_#{element.id}_content_group_size_header", text: "Size").click
        # 'Size' group now visible
        expect(page).to have_selector("#element_#{element.id}_content_group_size", visible: true)
        within("#element_#{element.id}_content_group_size") do
          expect(page).to have_selector("[data-#{type}-#{name_field}='width']")
          expect(page).to have_selector("[data-#{type}-#{name_field}='height']")
        end

        page.find("a#element_#{element.id}_content_group_size_header", text: "Size").click
        # 'Size' group hidden
        expect(page).not_to have_selector("#element_#{element.id}_content_group_size", visible: true)
      end

      scenario "expanded content groups persist between visits", :js do
        expect(page).not_to have_selector("#element_#{element.id}_content_group_details", visible: true)
        page.find("a#element_#{element.id}_content_group_details_header", text: "Details").click
        expect(page).to have_selector("#element_#{element.id}_content_group_details", visible: true)
        visit alchemy.edit_admin_page_path(element.page)
        expect(page).to have_selector("#element_#{element.id}_content_group_details", visible: true)
      end
    end
  end
end
