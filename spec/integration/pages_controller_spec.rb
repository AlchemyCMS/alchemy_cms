require 'ostruct'
require 'spec_helper'

module Alchemy
  describe PagesController do

    before(:all) do
      @default_language = Language.get_default
      @default_language_root = FactoryGirl.create(:language_root_page, :language => @default_language, :name => 'Home')
    end

    describe "#show" do

      it "should include all its elements and contents" do
        p = FactoryGirl.create(:public_page, :language => @default_language)
        article = p.elements.find_by_name('article')
        article.content_by_name('intro').essence.update_attributes(:body => 'Welcome to Peters Petshop', :public => true)
        visit "/alchemy/#{p.urlname}"
        within('div#content div.article div.intro') { page.should have_content('Welcome to Peters Petshop') }
      end

      it "should show the navigation with all visible pages" do
        pages = [
          FactoryGirl.create(:public_page, :language => @default_language, :visible => true, :name => 'Page 1', :parent_id => @default_language_root.id),
          FactoryGirl.create(:public_page, :language => @default_language, :visible => true, :name => 'Page 2', :parent_id => @default_language_root.id)
        ]
        visit '/alchemy/'
        within('div#navigation ul') { page.should have_selector('li a[href="/alchemy/page-1"], li a[href="/alchemy/page-2"]') }
      end

    end

    describe "fulltext search" do

      before(:all) do
        @page = FactoryGirl.create(:public_page, :language => @default_language, :visible => true, :name => 'Page 1', :parent_id => @default_language_root.id)
        @element = FactoryGirl.create(:element, :name => 'article', :page => @page)
        FactoryGirl.create(:public_page, :language => @default_language, :name => 'Suche', :page_layout => 'search', :parent_id => @default_language_root.id)
      end

      it "should have a correct path in the form tag" do
        visit('/alchemy/suche')
        page.should have_selector('div#content form[action="/alchemy/suche"]')
      end

      context "performing the search" do

        it "should display search results for richtext essences" do
          @element.content_by_name('text').essence.update_attributes(:body => '<p>Welcome to Peters Petshop</p>', :public => true)
          visit('/alchemy/suche?query=Petshop')
          within('div#content .search_result') { page.should have_content('Petshop') }
        end

        it "should display search results for text essences" do
          @element.content_by_name('intro').essence.update_attributes(:body => 'Welcome to Peters Petshop', :public => true)
          visit('/alchemy/suche?query=Petshop')
          within('div#content .search_result') { page.should have_content('Petshop') }
        end

        it "should not find contents placed on global-pages (layoutpage => true)" do
          @page.update_attributes(:layoutpage => true)
          @element.content_by_name('intro').essence.update_attributes(:body => 'Welcome to Peters Petshop', :public => true)
          visit('/alchemy/suche?query=Petshop')
          within('div#content') { page.should have_css('h2.no_search_results') }
        end

        it "should not find contents placed on unpublished pages (public => false)" do
          @page.update_attributes(:public => false)
          @element.content_by_name('intro').essence.update_attributes(:body => 'Welcome to Peters Petshop', :public => true)
          visit('/alchemy/suche?query=Petshop')
          within('div#content') { page.should have_css('h2.no_search_results') }
        end

        it "should not find contents placed on restricted pages (restricted => true)" do
          @page.update_attributes(:restricted => true)
          @element.content_by_name('intro').essence.update_attributes(:body => 'Welcome to Peters Petshop', :public => true)
          visit('/alchemy/suche?query=Petshop')
          within('div#content') { page.should have_css('h2.no_search_results') }
        end

      end

    end

    describe "redirecting" do

      context "in multi language mode" do

        before(:each) do
          @page = FactoryGirl.create(:public_page)
          Config.stub!(:get) { |arg| arg == :url_nesting ? true : Config.parameter(arg) }
        end

        it "should redirect to url with nested language code if no language params are given" do
          visit "/alchemy/#{@page.urlname}"
          page.current_path.should == "/alchemy/#{@page.language_code}/#{@page.urlname}"
        end

        context "should redirect to public child" do

          before(:each) do
            @page.update_attributes(:public => false, :name => 'Not Public', :urlname => '')
            @child = FactoryGirl.create(:public_page, :name => 'Public Child', :parent_id => @page.id)
            Config.stub!(:get) { |arg| arg == :url_nesting ? false : Config.parameter(arg) }
          end

          it "if requested page is unpublished" do
            visit '/alchemy/kl/not-public'
            page.current_path.should == '/alchemy/kl/public-child'
          end

          it "with nested language code, if requested page is unpublished and url has no language code" do
            visit '/alchemy/not-public'
            page.current_path.should == '/alchemy/kl/public-child'
          end

        end

        it "should redirect to pages url with default language, if requested url is index url" do
          visit '/alchemy/'
          page.current_path.should == '/alchemy/de/home'
        end

        it "should redirect to pages url with default language, if requested url is only the language code" do
          visit '/alchemy/de'
          page.current_path.should == '/alchemy/de/home'
        end

        context "requested url is only the urlname" do
          it "then it should redirect to pages url with nested language." do
            visit '/alchemy/home'
            page.current_path.should == '/alchemy/de/home'
          end
        end

        it "should keep additional params" do
          visit "/alchemy/#{@page.urlname}?query=Peter"
          page.current_url.should match(/\?query=Peter/)
        end

        it "should render 404 if urlname and lang parameter do not belong to same page" do
          User.stub!(:admins).and_return(OpenStruct.new(:count => 2))
          visit "/alchemy/en/#{@page.urlname}"
          page.status_code.should == 404
        end

        context "with url nesting" do

          before(:all) do
            @level1 = FactoryGirl.create(:public_page, :parent_id => @default_language_root.id, :name => 'catalog', :language => @default_language)
            @level2 = FactoryGirl.create(:public_page, :parent_id => @level1.id, :name => 'products', :language => @default_language)
            @level3 = FactoryGirl.create(:public_page, :parent_id => @level2.id, :name => 'screwdriver', :language => @default_language)
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

        before(:each) do
          @page = FactoryGirl.create(:public_page, :language => @default_language, :parent_id => @default_language_root.id)
          Config.stub!(:get) { |arg| arg == :url_nesting ? false : Config.parameter(arg) }
        end

        it "should redirect from nested language code url to normal url" do
          visit "/alchemy/de/#{@page.urlname}"
          page.current_path.should == "/alchemy/#{@page.urlname}"
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

          before(:each) do
            @page.update_attributes(:public => false, :name => 'Not Public', :urlname => '')
            @child = FactoryGirl.create(:public_page, :name => 'Public Child', :parent_id => @page.id, :language => @default_language)
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
          visit "/alchemy/de/#{@page.urlname}?query=Peter"
          page.current_url.should match(/\?query=Peter/)
        end

      end

    end

    describe "Handling of non-existing pages" do

      context "when a language root page exists" do

        before do
          User.stub!(:admins).and_return([1, 2]) # We need a admin user or the signup page will show up
          visit "/alchemy/non-existing-page"
        end

        it "should render the status code in the title tag" do
          within("title") { page.should have_content("404") }
        end

        it "should render the layout" do
          page.should have_selector("#language_select")
        end

      end

      context "404-Errors are handled by Rails now, so no need to test anymore.
               However, it still serves as documentation how they can be handled, so we leave it here" do

        it "should render public/404.html when it exists"
        it "can be handled by matching /404 and routing it to a controller of choice when no public/404.html exists"

      end

    end
  end
end
