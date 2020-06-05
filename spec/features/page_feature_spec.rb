# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Show page feature:", type: :system do
  let!(:default_language) { create(:alchemy_language) }

  let!(:default_language_root) do
    create(:alchemy_page, :language_root, language: default_language, name: "Home")
  end

  let(:public_page) do
    create(:alchemy_page, :public, name: "Page 1")
  end

  let(:public_child) do
    create(:alchemy_page, :public, name: "Public Child", parent_id: public_page.id)
  end

  context "When no page is present" do
    before do
      Alchemy::Page.delete_all
    end

    context "and no admin user is present yet" do
      before do
        Alchemy.user_class.delete_all
      end

      it "shows a welcome page" do
        visit "/"
        expect(page).to have_content("Welcome to Alchemy")
      end
    end
  end

  context "rendered" do
    let(:public_page) { create(:alchemy_page, :public, autogenerate_elements: true) }
    let(:article) { public_page.elements.find_by_name("article") }
    let(:essence) { article.content_by_name("intro").essence }

    before do
      essence.update_columns(body: "Welcome to Peters Petshop", public: true)
    end

    it "should include all its elements and contents" do
      visit "/#{public_page.urlname}"
      within("div#content div.article div.intro") do
        expect(page).to have_content("Welcome to Peters Petshop")
      end
    end
  end

  describe "Handling of non-existing pages" do
    before do
      # We need a admin user or the signup page will show up
      allow(Alchemy.user_class).to receive(:admins).and_return([1, 2])
    end

    it "should render public/404.html" do
      expect {
        visit "/non-existing-page"
      }.to raise_error(ActionController::RoutingError)
    end
  end

  describe "menubar" do
    context "rendering for guest users" do
      it "is prohibited" do
        visit "/#{public_page.urlname}"
        within("body") { expect(page).not_to have_selector("#alchemy_menubar") }
      end
    end

    context "rendering for members" do
      it "is prohibited" do
        authorize_user(build(:alchemy_dummy_user))
        visit "/#{public_page.urlname}"
        within("body") { expect(page).not_to have_selector("#alchemy_menubar") }
      end
    end

    context "rendering for authors" do
      it "is allowed" do
        authorize_user(:as_author)
        visit "/#{public_page.urlname}"
        within("body") { expect(page).to have_selector("#alchemy_menubar") }
      end
    end

    context "rendering for editors" do
      it "is allowed" do
        authorize_user(:as_editor)
        visit "/#{public_page.urlname}"
        within("body") { expect(page).to have_selector("#alchemy_menubar") }
      end
    end

    context "rendering for admins" do
      it "is allowed" do
        authorize_user(:as_admin)
        visit "/#{public_page.urlname}"
        within("body") { expect(page).to have_selector("#alchemy_menubar") }
      end
    end

    context "contains" do
      before do
        authorize_user(:as_admin)
        visit "/#{public_page.urlname}"
      end

      it "a link to the admin area" do
        within("#alchemy_menubar") do
          expect(page).to have_selector("li a[href='#{alchemy.admin_dashboard_url(host: Capybara.current_host)}']")
        end
      end

      it "a link to edit the current page" do
        within("#alchemy_menubar") do
          expect(page).to \
            have_selector("li a[href='#{alchemy.edit_admin_page_url(public_page, host: Capybara.current_host)}']")
        end
      end

      it "a form and button to logout of alchemy" do
        within("#alchemy_menubar") do
          expect(page).to \
            have_selector("li form[action='#{Alchemy.logout_path}'][method='post']")
          expect(page).to \
            have_selector("li form[action='#{Alchemy.logout_path}'] > button[type='submit']")
          expect(page).to \
            have_selector("li form[action='#{Alchemy.logout_path}'] > input[type='hidden'][name='_method'][value='#{Alchemy.logout_method}']")
        end
      end
    end
  end

  describe "navigation rendering" do
    context "with menu available" do
      let(:menu) { create(:alchemy_node, menu_type: "main_menu") }
      let(:page1) { create(:alchemy_page, :public, name: "Page 1") }
      let(:page2) { create(:alchemy_page, :public, name: "Page 2") }
      let!(:node1) { create(:alchemy_node, page: page1, parent: menu) }
      let!(:node2) { create(:alchemy_node, page: page2, parent: menu) }

      it "should show the navigation with all pages" do
        visit "/"
        within("nav ul") do
          expect(page).to have_selector('li a[href="/page-1"], li a[href="/page-2"]')
        end
      end

      it "shows the navigation in a custom controller" do
        visit "/ns/locations"
        within("nav ul") do
          expect(page).to have_selector('li a[href="/page-1"], li a[href="/page-2"]')
        end
      end
    end
  end

  describe "accessing restricted pages" do
    let!(:restricted_page) { create(:alchemy_page, :restricted, public_on: Time.current) }

    context "as a guest user" do
      it "I am not able to visit the page" do
        visit restricted_page.urlname
        expect(current_path).to eq(Alchemy.login_path)
      end
    end

    context "as a member user" do
      before do
        authorize_user(create(:alchemy_dummy_user))
      end

      it "I am able to visit the page" do
        visit restricted_page.urlname
        expect(current_path).to eq("/#{restricted_page.urlname}")
      end
    end
  end
end
