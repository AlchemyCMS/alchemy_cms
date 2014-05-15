require 'spec_helper'

describe 'Page editing feature' do
  let(:a_page) { FactoryGirl.create(:public_page, visible: true) }

  before { authorize_as_admin }

  context "in configure overlay" do

    context "when editing a normal page" do
      it "should show all relevant input fields" do
        visit alchemy.configure_admin_page_path(a_page)
        expect(page).to have_selector('input#page_urlname')
        expect(page).to have_selector('input#page_title')
        expect(page).to have_selector('input#page_robot_index')
        expect(page).to have_selector('input#page_robot_follow')
      end

      context "with sitemaps show_flag config option set to true" do
        before do
          Alchemy::Config.stub(:get) { |arg| arg == :sitemap ? {'show_flag' => true} : Alchemy::Config.show[arg.to_s] }
        end

        it "should show sitemap checkbox" do
          visit alchemy.configure_admin_page_path(a_page)
          expect(page).to have_selector('input[type="checkbox"]#page_sitemap')
        end
      end

      context "with sitemaps show_flag config option set to false" do
        before do
          Alchemy::Config.stub(:get) { |arg| arg == :sitemap ? {'show_flag' => false} : Alchemy::Config.show[arg.to_s] }
        end

        it "should show sitemap checkbox" do
          visit alchemy.configure_admin_page_path(a_page)
          expect(page).to_not have_selector('input[type="checkbox"]#page_sitemap')
        end
      end
    end

    context "when editing a global page" do
      let(:layout_page) { FactoryGirl.create(:page, layoutpage: true) }

      it "should not show the input fields for normal pages" do
        visit alchemy.edit_admin_layoutpage_path(layout_page)
        expect(page).to_not have_selector('input#page_urlname')
        expect(page).to_not have_selector('input#page_title')
        expect(page).to_not have_selector('input#page_robot_index')
        expect(page).to_not have_selector('input#page_robot_follow')
      end
    end

    context "when page is taggable" do
      before { Alchemy::Page.any_instance.stub(:taggable?).and_return(true) }
      it "should show the tag_list input field" do
        visit alchemy.configure_admin_page_path(a_page)
        expect(page).to have_selector('input#page_tag_list')
      end
    end
  end

  context "in preview frame" do
    it "the menubar does not render on the page" do
      visit alchemy.admin_page_path(a_page)
      page.should_not have_selector('#alchemy_menubar')
    end

    it "navigation links are not clickable" do
      visit alchemy.admin_page_path(a_page)
      within('#navigation') do
        page.should have_selector('a[href="javascript: void(0)"]')
      end
    end
  end
end
