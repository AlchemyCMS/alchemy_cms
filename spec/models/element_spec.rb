require 'spec_helper'

describe Element do

	context "scoped" do

	  before(:each) do
			Element.delete_all
	  end

		it "should return all public elements" do
			elements = [FactoryGirl.create(:element, :public => true), FactoryGirl.create(:element, :public => true)]
		  Element.published.all.should == elements
		end

		it "should return all elements by name" do
			elements = [FactoryGirl.create(:element, :name => 'article'), FactoryGirl.create(:element, :name => 'article')]
		  Element.named(['article']).all.should == elements
		end

		it "should return all elements but excluded ones" do
			FactoryGirl.create(:element, :name => 'article')
			FactoryGirl.create(:element, :name => 'article')
			excluded = [FactoryGirl.create(:element, :name => 'claim')]
		  Element.excluded(['article']).all.should == excluded
		end

	end

  it "should return a list of element definitions for a list of element names" do
		element_names = ["article"]
		definitions = Element.all_definitions_for(element_names)
		definitions.first.fetch("name").should == 'article'
  end

	it "should always return an array calling all_definitions_for()" do
		definitions = Element.all_definitions_for(nil)
		definitions.should == []
	end

	it "should raise an error if no descriptions are found" do
		FileUtils.mv(File.join(File.dirname(__FILE__), '..', '..', 'config', 'alchemy', 'elements.yml'), File.join(File.dirname(__FILE__), '..', '..', 'config', 'alchemy', 'elements.yml.bak'))
		expect { Element.descriptions }.should raise_error
		FileUtils.mv(File.join(File.dirname(__FILE__), '..', '..', 'config', 'alchemy', 'elements.yml.bak'), File.join(File.dirname(__FILE__), '..', '..', 'config', 'alchemy', 'elements.yml'))
	end

	context "retrieving contents, essences and ingredients" do

		before(:each) do
			@element = FactoryGirl.create(:element, :name => 'news')
		end

		it "should return an ingredient by name" do
			@element.ingredient('news_headline').should == EssenceText.first.ingredient
		end

		it "should return the content for rss title" do
			@element.content_for_rss_title.should == @element.contents.find_by_name('news_headline')
		end

		it "should return the content for rss description" do
			@element.content_for_rss_description.should == @element.contents.find_by_name('body')
		end

	end

	it "should return a collection of trashed elements" do
	  @element = FactoryGirl.create(:element)
		@element.trash
		Element.trashed.should include(@element)
	end

	context "trashed" do

		before(:each) do
		  @element = FactoryGirl.create(:element)
			@element.trash
		end

		it "should be not public" do
	   	@element.public.should be_false
		end

		it "should have no page" do
			@element.page.should == nil
		end

		it "should be folded" do
	    @element.folded.should == true
		end

	end

	it "should raise error if all_for_page method has no page" do
	  expect { Element.all_for_page(nil) }.should raise_error(TypeError)
	end

end
