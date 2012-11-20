require 'ostruct'
require 'spec_helper'

module Alchemy
  describe PagesController do

    let(:default_language) { Language.get_default }
    let(:default_language_root) { FactoryGirl.create(:language_root_page, :language => default_language, :name => 'Home') }
    let(:public_page_1) { FactoryGirl.create(:public_page, :visible => true, :name => 'Page 1') }
    let(:public_child) { FactoryGirl.create(:public_page, :name => 'Public Child', :parent_id => public_page_1.id) }
    let(:search_page) { FactoryGirl.create(:public_page, :name => 'Suche', :page_layout => 'search', :do_not_autogenerate => false) }
    let(:element) { FactoryGirl.create(:element, :page => public_page_1, :create_contents_after_create => true) }

    before { default_language_root }

    describe "#show" do

      it "should include all its elements and contents" do
        p = FactoryGirl.create(:public_page, :do_not_autogenerate => false)
        article = p.elements.find_by_name('article')
        article.content_by_name('intro').essence.update_attributes(:body => 'Welcome to Peters Petshop', :public => true)
        visit "/alchemy/#{p.urlname}"
        within('div#content div.article div.intro') { page.should have_content('Welcome to Peters Petshop') }
      end

      it "should show the navigation with all visible pages" do
        pages = [
          FactoryGirl.create(:public_page, :visible => true, :name => 'Page 1'),
          FactoryGirl.create(:public_page, :visible => true, :name => 'Page 2')
        ]
        visit '/alchemy/'
        within('div#navigation ul') { page.should have_selector('li a[href="/alchemy/page-1"], li a[href="/alchemy/page-2"]') }
      end

    end

    describe "fulltext search" do

      before { search_page }

      it "should have a correct path in the form tag" do
        visit('/alchemy/suche')
        page.should have_selector('div#content form[action="/alchemy/suche"]')
      end

      context "performing the search" do

        it "should display search results for richtext essences" do
          element.content_by_name('text').essence.update_attributes(:body => '<p>Welcome to Peters Petshop</p>')
          visit('/alchemy/suche?query=Petshop')
          within('div#content .search_result') { page.should have_content('Petshop') }
        end

        it "should display search results for text essences" do
          element.content_by_name('intro').essence.update_attributes(:body => 'Welcome to Peters Petshop')
          visit('/alchemy/suche?query=Petshop')
          within('div#content .search_result') { page.should have_content('Petshop') }
        end

        it "should not find contents placed on global-pages (layoutpage => true)" do
          public_page_1.update_attributes(:layoutpage => true)
          element.content_by_name('intro').essence.update_attributes(:body => 'Welcome to Peters Petshop')
          visit('/alchemy/suche?query=Petshop')
          within('div#content') { page.should have_css('h2.no_search_results') }
        end

        it "should not find contents placed on unpublished pages (public => false)" do
          public_page_1.update_attributes(:public => false)
          element.content_by_name('intro').essence.update_attributes(:body => 'Welcome to Peters Petshop')
          visit('/alchemy/suche?query=Petshop')
          within('div#content') { page.should have_css('h2.no_search_results') }
        end

        it "should not find contents placed on restricted pages (restricted => true)" do
          public_page_1.update_attributes(:restricted => true)
          element.content_by_name('intro').essence.update_attributes(:body => 'Welcome to Peters Petshop')
          visit('/alchemy/suche?query=Petshop')
          within('div#content') { page.should have_css('h2.no_search_results') }
        end

        context "in multi_language mode" do

          let(:english_language)      { FactoryGirl.create(:english) }
          let(:english_language_root) { FactoryGirl.create(:language_root_page, :language => english_language, :name => 'Home') }
          let(:english_page)          { FactoryGirl.create(:public_page, :parent_id => english_language_root.id, :language => english_language) }
          let(:english_element)       { FactoryGirl.create(:element, :page_id => english_page.id, :name => 'headline', :create_contents_after_create => true) }

          before do
            element
            english_element
            controller.stub!(:multi_language?).and_return(true)
          end

          it "should not display search results from other languages then current" do
            english_element.content_by_name('headline').essence.update_attributes(:body => 'Joes Hardware')
            visit('/alchemy/de/suche?query=Hardware')
            within('div#content') { page.should have_css('h2.no_search_results') }
            page.should_not have_css('div#content .search_result')
          end

        end

      end

    end

    describe "redirecting" do

      context "in multi language mode" do

        before do
          Config.stub!(:get) { |arg| arg == :url_nesting ? true : Config.parameter(arg) }
          PagesController.any_instance.stub(:multi_language?).and_return(true)
        end

        context "if no language params are given" do
          it "should redirect to url with nested language code" do
            visit "/alchemy/#{public_page_1.urlname}"
            page.current_path.should == "/alchemy/#{public_page_1.language_code}/#{public_page_1.urlname}"
          end
        end

        context "if requested page is unpublished" do

          before do
            public_page_1.update_attributes(:public => false, :name => 'Not Public', :urlname => '')
            public_child
            Config.stub!(:get) { |arg| arg == :url_nesting ? false : Config.parameter(arg) }
          end

          it "should redirect to public child" do
            visit "/alchemy/#{default_language.code}/not-public"
            page.current_path.should == "/alchemy/#{default_language.code}/public-child"
          end

          context "and url has no language code" do
            it "should redirect to url of public child with language code of default language" do
              visit '/alchemy/not-public'
              page.current_path.should == "/alchemy/#{default_language.code}/public-child"
            end
          end

        end

        context "if requested url is index url" do
          it "should redirect to pages url with default language" do
            visit '/alchemy/'
            page.current_path.should == "/alchemy/#{default_language.code}/home"
          end
        end

        context "if requested url is only the language code" do
          it "should redirect to pages url with default language" do
            visit "/alchemy/#{default_language.code}"
            page.current_path.should == "/alchemy/#{default_language.code}/home"
          end
        end

        context "requested url is only the urlname" do
          it "then it should redirect to pages url with nested language." do
            visit '/alchemy/home'
            page.current_path.should == '/alchemy/de/home'
          end
        end

        it "should keep additional params" do
          visit "/alchemy/#{public_page_1.urlname}?query=Peter"
          page.current_url.should match(/\?query=Peter/)
        end

        context "wrong language requested" do

          before { User.stub!(:admins).and_return([1, 2]) }

          it "should render 404 if urlname and lang parameter do not belong to same page" do
            FactoryGirl.create(:english)
            visit "/alchemy/en/#{public_page_1.urlname}"
            page.status_code.should == 404
          end

          it "should render 404 if requested language does not exist" do
            visit "/alchemy/fo/#{public_page_1.urlname}"
            page.status_code.should == 404
          end

        end

        context "with url nesting" do

          before do
            level1 = FactoryGirl.create(:public_page, :name => 'catalog')
            level2 = FactoryGirl.create(:public_page, :parent_id => level1.id, :name => 'products')
            level3 = FactoryGirl.create(:public_page, :parent_id => level2.id, :name => 'screwdriver')
          end

          context "enabled" do

            before(:each) do
              Config.stub!(:get) { |arg| arg == :url_nesting ? true : Config.parameter(arg) }
            end

            context "requesting a non nested url" do

              it "should redirect to nested url" do
                visit "/alchemy/de/screwdriver"
                page.current_path.should == '/alchemy/de/catalog/products/screwdriver'
              end

              it "should only redirect to nested url if page is nested" do
                visit "/alchemy/de/catalog"
                page.status_code.should == 200
                page.current_path.should == "/alchemy/de/catalog"
              end

            end

          end

          context "disabled" do

            before(:each) do
              Config.stub!(:get) { |arg| arg == :url_nesting ? false : Config.parameter(arg) }
            end

            context "requesting a nested url" do

              it "should redirect to not nested url" do
                visit "/alchemy/de/catalog/products/screwdriver"
                page.current_path.should == "/alchemy/de/screwdriver"
              end

            end

          end

        end

      end

      context "not in multi language mode" do

        before do
          PagesController.any_instance.stub(:multi_language?).and_return(false)
          Config.stub!(:get) { |arg| arg == :url_nesting ? false : Config.parameter(arg) }
        end

        it "should redirect from nested language code url to normal url" do
          visit "/alchemy/de/#{public_page_1.urlname}"
          page.current_path.should == "/alchemy/#{public_page_1.urlname}"
        end

        context "with no lang parameter" do

          it "should have defaults language language_id in the session" do
            get show_page_path(:urlname => 'a-public-page')
            controller.session[:language_id].should == Language.get_default.id
          end

          it "should have defaults language language_code in the session" do
            get show_page_path(:urlname => 'a-public-page')
            controller.session[:language_code].should == Language.get_default.code
          end

        end

        context "should redirect to public child" do

          before do
            public_page_1.update_attributes(:public => false, :name => 'Not Public', :urlname => '')
            public_child
          end

          it "if requested page is unpublished" do
            visit '/alchemy/not-public'
            page.current_path.should == '/alchemy/public-child'
          end

          it "with normal url, if requested url has nested language code and is not public" do
            visit '/alchemy/de/not-public'
            page.current_path.should == '/alchemy/public-child'
          end

        end

        it "should redirect to pages url, if requested url is index url" do
          visit '/alchemy/'
          page.current_path.should == '/alchemy/home'
        end

        it "should keep additional params" do
          visit "/alchemy/de/#{public_page_1.urlname}?query=Peter"
          page.current_url.should match(/\?query=Peter/)
        end

      end

    end

    describe "Handling of non-existing pages" do

      before do
        User.stub!(:admins).and_return([1, 2]) # We need a admin user or the signup page will show up
        visit "/alchemy/non-existing-page"
      end

      context "if a language root page exists" do

        it "should render the status code in the title tag" do
          within("title") { page.should have_content("404") }
        end

      end

      it "should render public/404.html when it exists" do
        within("title") { page.should have_content("404") }
      end

      it "can be handled by matching /404 and routing it to a controller of choice when no public/404.html exists"

    end
  end
end
