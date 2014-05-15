require 'spec_helper'

module Alchemy
  describe 'Page' do
    let(:default_language)      { Language.default }
    let(:default_language_root) { FactoryGirl.create(:language_root_page, :language => default_language, :name => 'Home') }
    let(:public_page_1)         { FactoryGirl.create(:public_page, :visible => true, :name => 'Page 1') }
    let(:public_child)          { FactoryGirl.create(:public_page, :name => 'Public Child', :parent_id => public_page_1.id) }

    before { default_language_root }

    it "should include all its elements and contents" do
      p = FactoryGirl.create(:public_page, :do_not_autogenerate => false)
      article = p.elements.find_by_name('article')
      article.content_by_name('intro').essence.update_attributes(:body => 'Welcome to Peters Petshop', :public => true)
      visit "/#{p.urlname}"
      within('div#content div.article div.intro') { page.should have_content('Welcome to Peters Petshop') }
    end

    it "should show the navigation with all visible pages" do
      pages = [
        FactoryGirl.create(:public_page, :visible => true, :name => 'Page 1'),
        FactoryGirl.create(:public_page, :visible => true, :name => 'Page 2')
      ]
      visit '/'
      within('div#navigation ul') { page.should have_selector('li a[href="/page-1"], li a[href="/page-2"]') }
    end

    describe "redirecting" do
      context "in multi language mode" do
        before do
          Config.stub(:get) { |arg| arg == :url_nesting ? true : Config.parameter(arg) }
          PagesController.any_instance.stub(:multi_language?).and_return(true)
        end

        context "if no language params are given" do
          it "should redirect to url with nested language code" do
            visit "/#{public_page_1.urlname}"
            page.current_path.should == "/#{public_page_1.language_code}/#{public_page_1.urlname}"
          end
        end

        context "if requested page is unpublished" do
          before do
            Config.stub(:get) { |arg| arg == :url_nesting ? false : Config.parameter(arg) }
            public_page_1.update_attributes(:public => false, :name => 'Not Public', :urlname => '')
            public_child
          end

          it "should redirect to public child" do
            visit "/#{default_language.code}/not-public"
            page.current_path.should == "/#{default_language.code}/public-child"
          end

          context "and url has no language code" do
            it "should redirect to url of public child with language code of default language" do
              visit '/not-public'
              page.current_path.should == "/#{default_language.code}/public-child"
            end
          end
        end

        context "if requested url is index url" do
          it "should redirect to pages url with default language" do
            visit '/'
            page.current_path.should == "/#{default_language.code}/home"
          end
        end

        context "if requested url is only the language code" do
          it "should redirect to pages url with default language" do
            visit "/#{default_language.code}"
            page.current_path.should == "/#{default_language.code}/home"
          end
        end

        context "requested url is only the urlname" do
          it "then it should redirect to pages url with nested language." do
            visit '/home'
            page.current_path.should == '/en/home'
          end
        end

        it "should keep additional params" do
          visit "/#{public_page_1.urlname}?query=Peter"
          page.current_url.should match(/\?query=Peter/)
        end

        context "wrong language requested" do
          before { Alchemy.user_class.stub(:admins).and_return([1, 2]) }

          it "should render 404 if urlname and lang parameter do not belong to same page" do
            FactoryGirl.create(:klingonian)
            visit "/kl/#{public_page_1.urlname}"
            page.status_code.should == 404
          end

          it "should render 404 if requested language does not exist" do
            public_page_1
            LegacyPageUrl.delete_all
            visit "/fo/#{public_page_1.urlname}"
            page.status_code.should == 404
          end
        end
      end

      context "not in multi language mode" do
        before do
          PagesController.any_instance.stub(:multi_language?).and_return(false)
          Config.stub(:get) { |arg| arg == :url_nesting ? false : Config.parameter(arg) }
        end

        it "should redirect from nested language code url to normal url" do
          visit "/en/#{public_page_1.urlname}"
          page.current_path.should == "/#{public_page_1.urlname}"
        end

        context "should redirect to public child" do
          before do
            public_page_1.update_attributes(:public => false, :name => 'Not Public', :urlname => '')
            public_child
          end

          it "if requested page is unpublished" do
            visit '/not-public'
            page.current_path.should == '/public-child'
          end

          it "with normal url, if requested url has nested language code and is not public" do
            visit '/en/not-public'
            page.current_path.should == '/public-child'
          end
        end

        it "should redirect to pages url, if requested url is index url" do
          visit '/'
          page.current_path.should == '/home'
        end

        it "should keep additional params" do
          visit "/de/#{public_page_1.urlname}?query=Peter"
          page.current_url.should match(/\?query=Peter/)
        end
      end
    end

    describe "Handling of non-existing pages" do
      before do
        Alchemy.user_class.stub(:admins).and_return([1, 2]) # We need a admin user or the signup page will show up
        visit "/non-existing-page"
      end

      it "should render public/404.html" do
        page.status_code.should == 404
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
          within('body') { page.should_not have_selector('#alchemy_menubar') }
        end
      end

      context "rendering for members" do
        it "is prohibited" do
          authorize_as_admin(mock_model('DummyUser', alchemy_roles: %w(member), language: 'en'))
          visit "/#{public_page_1.urlname}"
          within('body') { page.should_not have_selector('#alchemy_menubar') }
        end
      end

      context "rendering for authors" do
        it "is allowed" do
          authorize_as_admin(mock_model('DummyUser', alchemy_roles: %w(author), language: 'en', cache_key: 'aaa'))
          visit "/#{public_page_1.urlname}"
          within('body') { page.should have_selector('#alchemy_menubar') }
        end
      end

      context "rendering for editors" do
        it "is allowed" do
          authorize_as_admin(mock_model('DummyUser', alchemy_roles: %w(editor), language: 'en', cache_key: 'aaa'))
          visit "/#{public_page_1.urlname}"
          within('body') { page.should have_selector('#alchemy_menubar') }
        end
      end

      context "rendering for admins" do
        it "is allowed" do
          authorize_as_admin(mock_model('DummyUser', alchemy_roles: %w(admin), language: 'en', cache_key: 'aaa'))
          visit "/#{public_page_1.urlname}"
          within('body') { page.should have_selector('#alchemy_menubar') }
        end
      end

      context "contains" do
        before do
          authorize_as_admin(mock_model('DummyUser', alchemy_roles: %w(admin), language: 'en', cache_key: 'aaa'))
          visit "/#{public_page_1.urlname}"
        end

        it "a link to the admin area" do
          within('#alchemy_menubar') { page.should have_selector("li a[href='#{alchemy.admin_dashboard_path}']") }
        end

        it "a link to edit the current page" do
          within('#alchemy_menubar') { page.should have_selector("li a[href='#{alchemy.edit_admin_page_path(public_page_1)}']") }
        end

        it "a form and button to logout of alchemy" do
          within('#alchemy_menubar') { page.should have_selector("li form[action='#{Alchemy.logout_path}'], li button[type='submit']") }
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

  end
end
