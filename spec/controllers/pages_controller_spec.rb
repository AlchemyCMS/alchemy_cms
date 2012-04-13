require 'spec_helper'

describe Alchemy::PagesController do

  render_views

  before(:each) do
    @default_language = Alchemy::Language.get_default
    @default_language_root = Factory(:language_root_page, :language => @default_language, :name => 'Home', :public => true)
  end

  context "requested for a page containing a feed" do

    before(:each) do
      @page = Factory(:public_page, :parent_id => @default_language_root.id, :page_layout => 'news', :name => 'News', :language => @default_language)
    end

    it "should render a rss feed" do
      get :show, :urlname => 'news', :format => :rss
      response.content_type.should == 'application/rss+xml'
    end

    it "should include content" do
      @page.elements.first.content_by_name('news_headline').essence.update_attributes({:body => 'Peters Petshop'})
      get :show, :urlname => 'news', :format => :rss
      response.body.should match /Peters Petshop/
    end

  end

  context "requested for a page that does not contain a feed" do

    it "should render xml 404 error" do
      get :show, :urlname => 'home', :format => :rss
      response.status.should == 404
    end

  end

  describe "Layout rendering" do

    context "with param layout set to none" do

      it "should not render a layout" do
        get :show, :urlname => :home, :layout => false
        response.body.should_not have_content('<head>')
      end

    end

    context "with param layout set to a custom layout" do

      before do
        @custom_layout = Rails.root.join('app/views/layouts', 'custom.html.erb')
        File.open(@custom_layout, 'w') do |custom_layout|
          custom_layout.puts "<html>I am a custom layout</html>"
        end
      end

      it "should render the custom layout" do
        get :show, :urlname => :home, :layout => 'custom'
        response.body.should have_content('I am a custom layout')
      end

      after do
        FileUtils.rm(@custom_layout)
      end

    end

    context "with application layout absent" do

      it "should render pages layout" do
        get :show, :urlname => :home
        response.body.should_not have_content('I am the application layout')
      end

    end

    context "with application layout present" do

      before do
        @app_layout = Rails.root.join('app/views/layouts', 'application.html.erb')
        File.open(@app_layout, 'w') do |app_layout|
          app_layout.puts "<html>I am the application layout</html>"
        end
      end

      it "should render application layout" do
        get :show, :urlname => :home
        response.body.should have_content('I am the application layout')
      end

      after do
        FileUtils.rm(@app_layout)
      end

    end

  end

  describe "url nesting" do

    before(:each) do
      @catalog = Factory(:public_page, :name => "Catalog", :parent_id => @default_language_root.id, :language => @default_language)
      @products = Factory(:public_page, :name => "Products", :parent_id => @catalog.id, :language => @default_language)
      @product = Factory(:public_page, :name => "Screwdriver", :parent_id => @products.id, :language => @default_language)
      @product.elements.find_by_name('article').contents.essence_texts.first.essence.update_attribute(:body, 'screwdriver')
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
      Factory(:admin_user) # otherwise we are redirected to create_user
      get :show, {:urlname => 'doesntexist'}
      response.status.should == 404
      response.body.should have_content('The page you were looking for doesn\'t exist')
    end
  end

end
