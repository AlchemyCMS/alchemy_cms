# frozen_string_literal: true

require 'spec_helper'

RSpec.feature "The edit elements feature" do
  let!(:a_page) { create(:alchemy_page) }

  background do
    authorize_user(:as_editor)
  end

  context 'Visiting the new element form' do
    context 'with a page_id passed' do
      scenario 'a form to select a new element for the page appears.' do
        visit alchemy.new_admin_element_path(page_id: a_page.id)
        expect(page).to have_selector('select[name="element[name]"]')
      end
    end

    context 'with a page_id and parent_element_id passed' do
      let!(:element) { create(:alchemy_element, :with_nestable_elements, page: a_page) }

      scenario 'a hidden field with parent element id is in the form.' do
        visit alchemy.new_admin_element_path(page_id: a_page.id, parent_element_id: element.id)
        expect(page).to have_selector(%(input[type="hidden"][name="element[parent_element_id]"][value="#{element.id}"]))
      end
    end
  end

  context 'With an element having nestable elements defined' do
    let!(:element) { create(:alchemy_element, :with_nestable_elements, page: a_page) }

    scenario 'a button to add an nestable element appears.' do
      visit alchemy.admin_elements_path(page_id: element.page_id)
      expect(page).to have_selector('.add-nestable-element-button')
    end
  end
end
