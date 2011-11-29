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

end
