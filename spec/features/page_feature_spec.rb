require 'spec_helper'

module Alchemy
  describe 'Show page feature:' do
    let!(:default_language) { Language.default }

    let!(:default_language_root) do
      create(:alchemy_page, :language_root, language: default_language, name: 'Home')
    end

    let(:public_page) do
      create(:alchemy_page, :public, visible: true, name: 'Page 1')
    end

    let(:public_child) do
      create(:alchemy_page, :public, name: 'Public Child', parent_id: public_page.id)
    end

    context "When no page is present" do
      before do
        Alchemy::Page.delete_all
      end

      context "and no admin user is present yet" do
        before do
          Alchemy.user_class.delete_all
        end

        it 'shows a welcome page' do
          visit "/"
          expect(page).to have_content('Welcome to Alchemy')
        end
      end
    end

    context 'rendered' do
      let(:public_page) { create(:alchemy_page, :public, do_not_autogenerate: false) }
      let(:article) { public_page.elements.find_by_name('article') }
      let(:essence) { article.content_by_name('intro').essence }

      before do
        essence.update_attributes(body: 'Welcome to Peters Petshop', public: true)
      end

      it "should include all its elements and contents" do
        visit "/#{public_page.urlname}"
        within('div#content div.article div.intro') do
          expect(page).to have_content('Welcome to Peters Petshop')
        end
      end
    end

    it "should show the navigation with all visible pages" do
      create(:alchemy_page, :public, visible: true, name: 'Page 1')
      create(:alchemy_page, :public, visible: true, name: 'Page 2')
      visit '/'
      within('div#navigation ul') do
        expect(page).to have_selector('li a[href="/page-1"], li a[href="/page-2"]')
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

    context "with invalid byte code char in urlname parameter" do
      it "should raise BadRequest (400) error" do
        expect { visit '/%ed' }.to raise_error(ActionController::BadRequest)
      end
    end

    describe "menubar" do
      context "rendering for guest users" do
        it "is prohibited" do
          visit "/#{public_page.urlname}"
          within('body') { expect(page).not_to have_selector('#alchemy_menubar') }
        end
      end

      context "rendering for members" do
        it "is prohibited" do
          authorize_user(build(:alchemy_dummy_user))
          visit "/#{public_page.urlname}"
          within('body') { expect(page).not_to have_selector('#alchemy_menubar') }
        end
      end

      context "rendering for authors" do
        it "is allowed" do
          authorize_user(:as_author)
          visit "/#{public_page.urlname}"
          within('body') { expect(page).to have_selector('#alchemy_menubar') }
        end
      end

      context "rendering for editors" do
        it "is allowed" do
          authorize_user(:as_editor)
          visit "/#{public_page.urlname}"
          within('body') { expect(page).to have_selector('#alchemy_menubar') }
        end
      end

      context "rendering for admins" do
        it "is allowed" do
          authorize_user(:as_admin)
          visit "/#{public_page.urlname}"
          within('body') { expect(page).to have_selector('#alchemy_menubar') }
        end
      end

      context "contains" do
        before do
          authorize_user(:as_admin)
          visit "/#{public_page.urlname}"
        end

        it "a link to the admin area" do
          within('#alchemy_menubar') do
            expect(page).to have_selector("li a[href='#{alchemy.admin_dashboard_url}']")
          end
        end

        it "a link to edit the current page" do
          within('#alchemy_menubar') do
            expect(page).to \
              have_selector("li a[href='#{alchemy.edit_admin_page_url(public_page)}']")
          end
        end

        it "a form and button to logout of alchemy" do
          within('#alchemy_menubar') do
            expect(page).to \
              have_selector("li form[action='#{Alchemy.logout_path}'], li button[type='submit']")
          end
        end
      end
    end

    describe 'navigation rendering' do
      context 'with page having an external url without protocol' do
        let!(:external_page) do
          create(:alchemy_page, urlname: 'google.com', page_layout: 'external', visible: true)
        end

        it "adds an prefix to url" do
          visit "/#{public_page.urlname}"
          within '#navigation' do
            expect(page.body).to match('http://google.com')
          end
        end
      end
    end

    describe 'accessing restricted pages' do
      let!(:restricted_page) { create(:alchemy_page, :restricted, public_on: Time.current) }

      context 'as a guest user' do
        it "I am not able to visit the page" do
          visit restricted_page.urlname
          expect(current_path).to eq(Alchemy.login_path)
        end
      end

      context 'as a member user' do
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
end
