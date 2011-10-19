require 'spec_helper'

describe PagesHelper do

  context "method language_switches" do
	
		before :each do
			@default_language = Language.get_default
			@german = Factory(:language, :code => "de", :name => "Deutsch", :public => true)
			# simulates link_to_public_child = true
			helper.stub(:configuration).and_return(true)
			helper.stub(:multi_language?).and_return(true)
		end
		
		it "should return nil when having only one public language" do
			helper.stub(:configuration).and_return(true)
			helper.stub(:multi_language?).and_return(false)
			helper.language_switches.should be nil
		end
		
		context "with two public languages and two language_roots" do
			
			before :each do
				@default_language_root = Factory(:page, :language => @default_language, :parent_id => Page.root.id, :name => "home", :public => true, :language_root => true)
				@german_language_root = Factory(:page, :language => @german, :parent_id => Page.root.id, :name => "home", :public => true, :language_root => true)
			end
			
			context "and config redirect_to_public_child is set to TRUE" do
				
				before :each do
					# simulates link_to_public_child = true
					helper.stub(:configuration).and_return(true)
				end
				
				it "should return nil if only one language_root is public and both do not have children" do
					@german_language_root.update_attributes(:public => false)
					helper.language_switches.should == nil
				end
				
				it "should return nil if only one language_root is public and both have none public children" do
					@german_language_root.update_attributes(:public => false)
					@default_first_public_child = Factory(:page, :language => @default_language, :parent_id => @default_language_root.id, :public => false, :name => "child1")
					@german_first_public_child = Factory(:page, :language => @german, :parent_id => @german_language_root.id, :public => false, :name => "child1")
					helper.language_switches.should == nil
				end
				
				it "should render two links when having two public language_root pages" do
					helper.language_switches.should have_selector('a', :count => 2)
				end
			
				it "should render two links when having just one public language_root but a public children in both language_roots" do
					@german_language_root.update_attributes(:public => false)
					@default_first_public_child = Factory(:page, :language => @default_language, :parent_id => @default_language_root.id, :public => true, :name => "child1")
					@german_first_public_child = Factory(:page, :language => @german, :parent_id => @german_language_root.id, :public => true, :name => "child1")
					helper.language_switches.should have_selector('a', :count => 2)
				end
			
				it "should render two links when having two not public language_roots but a public children in both" do
					@default_language_root.update_attributes(:public => false)
					@german_language_root.update_attributes(:public => false)
					@default_first_public_child = Factory(:page, :language => @default_language, :parent_id => @default_language_root.id, :public => true, :name => "child1")
					@german_first_public_child = Factory(:page, :language => @german, :parent_id => @german_language_root.id, :public => true, :name => "child1")
					helper.language_switches.should have_selector('a', :count => 2)
				end
			
				it "should return nil when having two not public language_roots and a public children in only one of them" do
					@default_language_root.update_attributes(:public => false)
					@german_language_root.update_attributes(:public => false)
					@default_first_public_child = Factory(:page, :language => @default_language, :parent_id => @default_language_root.id, :public => false, :name => "child1")
					@german_first_public_child = Factory(:page, :language => @german, :parent_id => @german_language_root.id, :public => true, :name => "child1")
					helper.language_switches.should == nil
				end
				
			end
		
			context "and config redirect_to_public_child is set to FALSE" do
				
				before :each do
					# simulates link_to_public_child = false
					helper.stub(:configuration).and_return(false)
				end
				
				it "should render two links when having two public language_root pages" do
					helper.language_switches.should have_selector('a', :count => 2)
				end
				
				it "should render nil when having just one public language_root but a public children in both language_roots" do
					@german_language_root.update_attributes(:public => false)
					@default_first_public_child = Factory(:page, :language => @default_language, :parent_id => @default_language_root.id, :public => true, :name => "child1")
					@german_first_public_child = Factory(:page, :language => @german, :parent_id => @german_language_root.id, :public => true, :name => "child1")
					helper.language_switches.should == nil
				end
				
				it "should render nil when having two not public language_roots but a public children in both" do
					@default_language_root.update_attributes(:public => false)
					@german_language_root.update_attributes(:public => false)
					@default_first_public_child = Factory(:page, :language => @default_language, :parent_id => @default_language_root.id, :public => true, :name => "child1")
					@german_first_public_child = Factory(:page, :language => @german, :parent_id => @german_language_root.id, :public => true, :name => "child1")
					helper.language_switches.should == nil
				end
				
			end
		
		end
		
	end

end
