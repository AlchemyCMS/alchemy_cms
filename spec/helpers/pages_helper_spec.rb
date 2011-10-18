require 'spec_helper'

describe PagesHelper do

  describe "using the language_switches method" do
	
		before :each do
			@default_language = Language.get_default
			@german = Factory(:language, :code => "de", :name => "Deutsch", :public => true)
			# simulates link_to_public_child = true
			helper.stub(:configuration).and_return(true)
			helper.stub(:multi_language?).and_return(true)
		end
		
		it "should return nil when having only one public language" do
			helper.stub(:multi_language?).and_return(false)
			helper.language_switches.should be nil
		end
		
		it "should render an empty string when having more than one public language but only one language_root is public" do
			pending "It renders a link to the language. But do we need to render a language_switcher with one link? (we have only one accessible language tree) I think we dont..."
			@default_language_root = Factory(:page, :language => @default_language, :parent_id => Page.root.id, :name => "home", :public => true, :language_root => true)
			@german_language_root = Factory(:page, :language => @german, :parent_id => Page.root.id, :name => "home", :public => false, :language_root => true)
			helper.stub(:multi_language?).and_return(true)
			helper.language_switches.should == ''
		end
			
		it "should render two links when having two public language_root pages and a public children per page" do
			@default_language_root = Factory(:page, :language => @default_language, :parent_id => Page.root.id, :name => "home", :public => true, :language_root => true)
			@german_language_root = Factory(:page, :language => @german, :parent_id => Page.root.id, :name => "home", :public => true, :language_root => true)
			@default_first_public_child = Factory(:page, :language => @default_language, :parent_id => @default_language_root.id, :public => true, :name => "child1")
			@german_first_public_child = Factory(:page, :language => @german, :parent_id => @german_language_root.id, :public => true, :name => "child1")
			helper.language_switches.should have_selector('a', :count => 2)
		end
		
	end

end
