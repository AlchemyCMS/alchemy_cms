require 'spec_helper'

module Alchemy
  describe PagesController do

    let(:default_language)      { Language.get_default }
    let(:default_language_root) { FactoryGirl.create(:language_root_page, :language => default_language, :name => 'Home', :public => true) }

    context "requested for a page containing a feed" do
      render_views

      let(:page) { FactoryGirl.create(:public_page, :parent_id => default_language_root.id, :page_layout => 'news', :name => 'News', :language => default_language, :do_not_autogenerate => false) }

      it "should render a rss feed" do
        get :show, :urlname => page.urlname, :format => :rss
        response.content_type.should == 'application/rss+xml'
      end

      it "should include content" do
        page.elements.first.content_by_name('news_headline').essence.update_attributes({:body => 'Peters Petshop'})
        get :show, :urlname => 'news', :format => :rss
        response.body.should match /Peters Petshop/
      end

    end

    context "requested for a page that does not contain a feed" do

      it "should render xml 404 error" do
        get :show, :urlname => default_language_root.urlname, :format => :rss
        response.status.should == 404
      end

    end

    describe "Layout rendering" do

      context "with param layout set to none" do

        it "should not render a layout" do
          get :show, :urlname => :home, :layout => 'none'
          response.body.should_not match /<head>/
        end

      end

      context "with param layout set to false" do

        it "should not render a layout" do
          get :show, :urlname => :home, :layout => 'false'
          response.body.should_not match /<head>/
        end

      end

      context "with params layout set to not existing layout" do
        it "should raise ActionView::MissingTemplate" do
          expect {
            get :show, :urlname => default_language_root.urlname, :layout => 'lkuiuk'
          }.to raise_error(ActionView::MissingTemplate)
        end
      end

      context "with param layout set to a custom layout" do
        render_views

        before do
          @custom_layout = Rails.root.join('app/views/layouts', 'custom.html.erb')
          File.open(@custom_layout, 'w') do |custom_layout|
            custom_layout.puts "<html>I am a custom layout</html>"
          end
        end

        it "should render the custom layout" do
          get :show, :urlname => default_language_root.urlname, :layout => 'custom'
          response.body.should have_content('I am a custom layout')
        end

        after do
          FileUtils.rm(@custom_layout)
        end

      end
    end

    describe "url nesting" do
      render_views

      before(:each) do
        @catalog = FactoryGirl.create(:public_page, :name => "Catalog", :parent_id => default_language_root.id, :language => default_language)
        @products = FactoryGirl.create(:public_page, :name => "Products", :parent_id => @catalog.id, :language => default_language)
        @product = FactoryGirl.create(:public_page, :name => "Screwdriver", :parent_id => @products.id, :language => default_language, :do_not_autogenerate => false)
        @product.elements.find_by_name('article').contents.essence_texts.first.essence.update_column(:body, 'screwdriver')
        controller.stub!(:configuration) { |arg| arg == :url_nesting ? true : false }
      end

      context "with correct levelnames in params" do

        it "should show the requested page" do
          get :show, {:level1 => 'catalog', :level2 => 'products', :urlname => 'screwdriver'}
          response.status.should == 200
          response.body.should have_content("screwdriver")
        end

      end

      context "with incorrect levelnames in params" do

        it "should render a 404 page" do
          get :show, {:level1 => 'catalog', :level2 => 'faqs', :urlname => 'screwdriver'}
          response.status.should == 404
          response.body.should have_content('The page you were looking for doesn\'t exist')
        end

      end

    end

    context "when a non-existent page is requested" do
      it "should rescue a RoutingError with rendering a 404 page." do
        FactoryGirl.create(:admin_user) # otherwise we are redirected to create_user
        get :show, {:urlname => 'doesntexist'}
        response.status.should == 404
        response.body.should have_content('The page you were looking for doesn\'t exist')
      end
    end

    describe '#redirect_to_public_child' do

      let(:root_page)    { FactoryGirl.create(:language_root_page, :public => false) }
      let(:page)         { FactoryGirl.create(:page, :parent_id => root_page.id) }
      let(:public_page)  { FactoryGirl.create(:public_page, :parent_id => page.id) }

      before { controller.instance_variable_set("@page", root_page) }

      context "with unpublished and published pages in page tree" do

        before do
          public_page
          root_page.reload
        end

        it "should redirect to first public child" do
          controller.should_receive(:redirect_page)
          controller.send(:redirect_to_public_child)
          controller.instance_variable_get('@page').should == public_page
        end

      end

      context "with only unpublished pages in page tree" do

        before do
          page
          root_page.reload
        end

        it "should raise not found error" do
          expect {
            controller.send(:redirect_to_public_child)
          }.to raise_error(ActionController::RoutingError)
        end

      end
    end

    describe 'Redirecting to legacy page urls' do
      context 'Request a page with legacy url' do

        # otherwise we are redirected to signup
        before { FactoryGirl.create(:admin_user) }

        let(:page)        { FactoryGirl.create(:public_page, :name => 'New page name') }
        let(:second_page) { FactoryGirl.create(:public_page, :name => 'Second Page') }
        let(:legacy_page) { FactoryGirl.create(:public_page, :name => 'Legacy Url') }
        let(:legacy_url)  { LegacyPageUrl.create(:urlname => 'legacy-url', :page => page) }
        let(:legacy_url2) { LegacyPageUrl.create(:urlname => 'legacy-url', :page => second_page) }

        it "should redirect permanently to page that belongs to legacy page url." do
          get :show, :urlname => legacy_url.urlname
          response.status.should == 301
          response.should redirect_to('/new-page-name')
        end

        it "should only redirect to legacy url if no page was found for urlname" do
          legacy_url
          get :show, :urlname => legacy_page.urlname
          response.status.should == 200
          response.should_not redirect_to('/new-page-name')
        end

        it "should redirect to last page that has that legacy url" do
          legacy_url
          get :show, :urlname => legacy_url2.urlname
          response.should redirect_to('/second-page')
        end

      end
    end

    describe "while redirecting" do

      context "not in multi language mode" do

        before do
          PagesController.any_instance.stub(:multi_language?).and_return(false)
        end

        context "with no lang parameter present" do

          it "should store defaults language id in the session." do
            get :show, :urlname => 'a-public-page'
            controller.session[:language_id].should == Language.get_default.id
          end

          it "should store defaults language code in the session." do
            get :show, :urlname => 'a-public-page'
            controller.session[:language_code].should == Language.get_default.code
          end

        end

      end

    end

  end
end
