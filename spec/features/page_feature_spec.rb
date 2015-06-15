require 'spec_helper'

module Alchemy
  describe 'Page' do
    let(:default_language)      { Language.default }
    let(:default_language_root) { create(:language_root_page, :language => default_language, :name => 'Home') }
    let(:public_page_1)         { create(:public_page, :visible => true, :name => 'Page 1') }
    let(:public_child)          { create(:public_page, :name => 'Public Child', :parent_id => public_page_1.id) }

    before { default_language_root }

    it "should include all its elements and contents" do
      p = create(:public_page, :do_not_autogenerate => false)
      article = p.elements.find_by_name('article')
      article.content_by_name('intro').essence.update_attributes(:body => 'Welcome to Peters Petshop', :public => true)
      visit "/#{p.urlname}"
      within('div#content div.article div.intro') { expect(page).to have_content('Welcome to Peters Petshop') }
    end

    it "should show the navigation with all visible pages" do
      pages = [
        create(:public_page, :visible => true, :name => 'Page 1'),
        create(:public_page, :visible => true, :name => 'Page 2')
      ]
      visit '/'
      within('div#navigation ul') { expect(page).to have_selector('li a[href="/page-1"], li a[href="/page-2"]') }
    end

    describe "redirecting" do
      context "in multi language mode" do
        before do
          allow(Config).to receive(:get) { |arg| arg == :url_nesting ? true : Config.parameter(arg) }
          allow_any_instance_of(PagesController).to receive(:multi_language?).and_return(true)
        end

        let(:second_page) { create(:public_page, name: 'Second Page') }
        let(:legacy_url)  { LegacyPageUrl.create(urlname: 'index.php?option=com_content&view=article&id=48&Itemid=69', page: second_page) }

        it "should redirect legacy url with unknown format & query string" do
          visit "/#{legacy_url.urlname}"
          uri = URI.parse(page.current_url)
          expect(uri.query).to be_nil
          expect(uri.request_uri).to eq("/en/#{second_page.urlname}")
        end

        context "if no language params are given" do
          it "should redirect to url with nested language code" do
            visit "/#{public_page_1.urlname}"
            expect(page.current_path).to eq("/#{public_page_1.language_code}/#{public_page_1.urlname}")
          end
        end

        context "if requested page is unpublished" do
          before do
            allow(Config).to receive(:get) { |arg| arg == :url_nesting ? false : Config.parameter(arg) }
            public_page_1.update_attributes(:public => false, :name => 'Not Public', :urlname => '')
            public_child
          end

          it "should redirect to public child" do
            visit "/#{default_language.code}/not-public"
            expect(page.current_path).to eq("/#{default_language.code}/public-child")
          end

          context "and url has no language code" do
            it "should redirect to url of public child with language code of default language" do
              visit '/not-public'
              expect(page.current_path).to eq("/#{default_language.code}/public-child")
            end
          end
        end

        context "if requested url is index url" do
          it "should redirect to pages url with default language" do
            visit '/'
            expect(page.current_path).to eq("/#{default_language.code}/home")
          end
        end

        context "if requested url is only the language code" do
          it "should redirect to pages url with default language" do
            visit "/#{default_language.code}"
            expect(page.current_path).to eq("/#{default_language.code}/home")
          end
        end

        context "requested url is only the urlname" do
          it "then it should redirect to pages url with nested language." do
            visit '/home'
            expect(page.current_path).to eq('/en/home')
          end
        end

        it "should keep additional params" do
          visit "/#{public_page_1.urlname}?query=Peter"
          expect(page.current_url).to match(/\?query=Peter/)
        end

        context "wrong language requested" do
          before { allow(Alchemy.user_class).to receive(:admins).and_return([1, 2]) }

          it "should render 404 if urlname and lang parameter do not belong to same page" do
            create(:klingonian)
            expect {
              visit "/kl/#{public_page_1.urlname}"
            }.to raise_error(ActionController::RoutingError)
          end

          it "should render 404 if requested language does not exist" do
            public_page_1
            LegacyPageUrl.delete_all
            expect {
              visit "/fo/#{public_page_1.urlname}"
            }.to raise_error(ActionController::RoutingError)
          end
        end
      end

      context "not in multi language mode" do
        before do
          allow_any_instance_of(PagesController).to receive(:multi_language?).and_return(false)
          allow(Config).to receive(:get) { |arg| arg == :url_nesting ? false : Config.parameter(arg) }
        end

        let(:second_page) { create(:public_page, name: 'Second Page') }
        let(:legacy_url) { LegacyPageUrl.create(urlname: 'index.php?option=com_content&view=article&id=48&Itemid=69', page: second_page) }

        it "should redirect legacy url with unknown format & query string" do
          visit "/#{legacy_url.urlname}"
          uri = URI.parse(page.current_url)
          expect(uri.query).to be_nil
          expect(uri.request_uri).to eq("/#{second_page.urlname}")
        end

        it "should redirect from nested language code url to normal url" do
          visit "/en/#{public_page_1.urlname}"
          expect(page.current_path).to eq("/#{public_page_1.urlname}")
        end

        context "should redirect to public child" do
          before do
            public_page_1.update_attributes(:public => false, :name => 'Not Public', :urlname => '')
            public_child
          end

          it "if requested page is unpublished" do
            visit '/not-public'
            expect(page.current_path).to eq('/public-child')
          end

          it "with normal url, if requested url has nested language code and is not public" do
            visit '/en/not-public'
            expect(page.current_path).to eq('/public-child')
          end
        end

        it "should redirect to pages url, if requested url is index url" do
          visit '/'
          expect(page.current_path).to eq('/home')
        end

        it "should keep additional params" do
          visit "/en/#{public_page_1.urlname}?query=Peter"
          expect(page.current_url).to match(/\?query=Peter/)
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

    context "with invalid byte code char in urlname parameter" do
      it "should raise BadRequest (400) error" do
        expect { visit '/%ed' }.to raise_error(ActionController::BadRequest)
      end
    end

    describe "menubar" do
      context "rendering for guest users" do
        it "is prohibited" do
          visit "/#{public_page_1.urlname}"
          within('body') { expect(page).not_to have_selector('#alchemy_menubar') }
        end
      end

      context "rendering for members" do
        it "is prohibited" do
          authorize_user(build(:alchemy_dummy_user))
          visit "/#{public_page_1.urlname}"
          within('body') { expect(page).not_to have_selector('#alchemy_menubar') }
        end
      end

      context "rendering for authors" do
        it "is allowed" do
          authorize_user(:as_author)
          visit "/#{public_page_1.urlname}"
          within('body') { expect(page).to have_selector('#alchemy_menubar') }
        end
      end

      context "rendering for editors" do
        it "is allowed" do
          authorize_user(:as_editor)
          visit "/#{public_page_1.urlname}"
          within('body') { expect(page).to have_selector('#alchemy_menubar') }
        end
      end

      context "rendering for admins" do
        it "is allowed" do
          authorize_user(:as_admin)
          visit "/#{public_page_1.urlname}"
          within('body') { expect(page).to have_selector('#alchemy_menubar') }
        end
      end

      context "contains" do
        before do
          authorize_user(:as_admin)
          visit "/#{public_page_1.urlname}"
        end

        it "a link to the admin area" do
          within('#alchemy_menubar') do
            expect(page).to have_selector("li a[href='#{alchemy.admin_dashboard_path}']")
          end
        end

        it "a link to edit the current page" do
          within('#alchemy_menubar') do
            expect(page).to have_selector("li a[href='#{alchemy.edit_admin_page_path(public_page_1)}']")
          end
        end

        it "a form and button to logout of alchemy" do
          within('#alchemy_menubar') do
            expect(page).to have_selector("li form[action='#{Alchemy.logout_path}'], li button[type='submit']")
          end
        end
      end
    end

    describe 'navigation rendering' do
      context 'with page having an external url without protocol' do
        let!(:external_page) { create(:page, urlname: 'google.com', page_layout: 'external', visible: true) }

        it "adds an prefix to url" do
          visit "/#{public_page_1.urlname}"
          within '#navigation' do
            expect(page.body).to match('http://google.com')
          end
        end
      end
    end

    describe 'accessing restricted pages' do
      let!(:restricted_page) { create(:restricted_page, public: true) }

      context 'as a guest user' do
        it "I am not able to visit the page" do
          visit restricted_page.urlname
          expect(current_path).to eq(Alchemy.login_path)
        end
      end

      context 'as a member user' do
        before { authorize_user(create(:alchemy_dummy_user)) }

        it "I am able to visit the page" do
          visit restricted_page.urlname
          expect(current_path).to eq("/#{restricted_page.urlname}")
        end
      end
    end
  end
end
