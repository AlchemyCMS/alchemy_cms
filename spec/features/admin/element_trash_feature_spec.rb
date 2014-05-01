require 'spec_helper'

describe 'Element trash feature', js: true do
  before { authorize_as_admin }

  let(:a_page)  { FactoryGirl.create(:page, do_not_autogenerate: false) }
  let(:element) { a_page.elements.first }


  context "let one trash element" do

    before do
      visit edit_admin_page_path(a_page)
      within "#element_#{element.id}" do
        click_link Alchemy::I18n.t("trash element")
      end
    end

    it "should show element trash message" do
      expect(page).to have_content('Element trashed')
    end

    context "and let one create element afterwards" do

      before do
        within "#overlay_toolbar" do
          click_link Alchemy::I18n.t("New Element")
        end

        within ".new_alchemy_element" do
          select 'Article', from: "element[name]"
          click_button Alchemy::I18n.t(:add)
        end
      end

      it "should show element create message" do
        expect(page).to have_content(Alchemy::I18n.t(:successfully_added_element))
        expect(page).not_to have_content("position #{Alchemy::I18n.t(:taken)}")
      end

      context "and trash recently added element" do
        let(:lastelement) { a_page.elements.last }

        before do
          within "#element_#{lastelement.id}" do
            click_link Alchemy::I18n.t("trash element")
          end
        end

        it "should show element trash message" do
          expect(page).to have_content('Element trashed')
        end

        context "and check the bin for trashed elements" do

          before do
            within "#overlay_toolbar" do
              click_link Alchemy::I18n.t("Show trash")
            end
          end

          it "should contain recently trashed elements" do
            expect(page).to have_css('#trash_items')
          end
        end

        context "and create a new element afterwards" do

          before do
            within "#overlay_toolbar" do
              click_link Alchemy::I18n.t("New Element")
            end

            within ".new_alchemy_element" do
              select 'Article', from: "element[name]"
              click_button Alchemy::I18n.t(:add)
            end
          end

          it "it should show element create message" do
            expect(page).to have_content(Alchemy::I18n.t(:successfully_added_element))
            expect(page).not_to have_content("Position #{Alchemy::I18n.t(:taken)}")
          end
        end
      end
    end
  end
end
