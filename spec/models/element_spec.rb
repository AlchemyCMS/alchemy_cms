require 'spec_helper'

describe Alchemy::Element do

	context "scoped" do

	  before(:each) do
			Alchemy::Element.delete_all
	  end

		it "should return all public elements" do
			elements = [Factory(:element, :public => true), Factory(:element, :public => true)]
		  Alchemy::Element.published.all.should == elements
		end

		it "should return all elements by name" do
			elements = [Factory(:element, :name => 'article'), Factory(:element, :name => 'article')]
		  Alchemy::Element.named(['article']).all.should == elements
		end

		it "should return all elements but excluded ones" do
			Factory(:element, :name => 'article')
			Factory(:element, :name => 'article')
			excluded = [Factory(:element, :name => 'claim')]
		  Alchemy::Element.excluded(['article']).all.should == excluded
		end
		
		context "not_in_cell" do
		  it "should return all elements that are not in a cell" do
				Factory(:element, :cell_id => 6)
				Factory(:element, :cell_id => nil)
				Alchemy::Element.not_in_cell.should have(1).element
			end
		end

	end

  it "should return a list of element definitions for a list of element names" do
		element_names = ["article"]
		definitions = Alchemy::Element.all_definitions_for(element_names)
		definitions.first.fetch("name").should == 'article'
  end

	it "should always return an array calling all_definitions_for()" do
		definitions = Alchemy::Element.all_definitions_for(nil)
		definitions.should == []
	end

	it "should raise an error if no descriptions are found" do
		FileUtils.mv(File.join(File.dirname(__FILE__), '..', '..', 'config', 'alchemy', 'elements.yml'), File.join(File.dirname(__FILE__), '..', '..', 'config', 'alchemy', 'elements.yml.bak'))
		expect { Alchemy::Element.descriptions }.should raise_error
		FileUtils.mv(File.join(File.dirname(__FILE__), '..', '..', 'config', 'alchemy', 'elements.yml.bak'), File.join(File.dirname(__FILE__), '..', '..', 'config', 'alchemy', 'elements.yml'))
	end

	context "retrieving contents, essences and ingredients" do

		before(:each) do
			@element = Factory(:element, :name => 'news')
		end

		it "should return an ingredient by name" do
			@element.ingredient('news_headline').should == Alchemy::EssenceText.first.ingredient
		end

		it "should return the content for rss title" do
			@element.content_for_rss_title.should == @element.contents.find_by_name('news_headline')
		end

		it "should return the content for rss description" do
			@element.content_for_rss_description.should == @element.contents.find_by_name('body')
		end

	end

	it "should return a collection of trashed elements" do
	  @element = Factory(:element)
		@element.trash
		Alchemy::Element.trashed.should include(@element)
	end

	context "trashed" do

		before(:each) do
		  @element = Factory(:element)
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
	  expect { Alchemy::Element.all_for_page(nil) }.should raise_error(TypeError)
	end

	describe "#content_by_type" do

		before(:each) do
			@element = Factory(:element, :name => 'headline')
			@content = @element.contents.first
		end

		context "with namespaced essence type" do

			it "should return content by passing a essence type" do
				@element.content_by_type('Alchemy::EssenceText').should == @content
			end

		end

		context "without namespaced essence type" do

			it "should return content by passing a essence type" do
				@element.content_by_type('EssenceText').should == @content
			end

		end

	end

	describe "#all_contents_by_type" do

		before(:each) do
			@element = Factory(:element)
			@contents = @element.contents.select { |c| c.essence_type == 'Alchemy::EssenceText' }
		end

		context "with namespaced essence type" do

			it "should return content by passing a essence type" do
				@element.all_contents_by_type('Alchemy::EssenceText').should == @contents
			end

		end

		context "without namespaced essence type" do

			it "should return content by passing a essence type" do
				@element.all_contents_by_type('EssenceText').should == @contents
			end

		end

	end

	describe '#copy' do

		before(:each) do
			@element = Factory(:element)
		end

		it "should not create contents from scratch" do
			copy = Alchemy::Element.copy(@element)
			copy.contents.count.should == @element.contents.count
		end

		it "should create a new record with all attributes of source except given differences" do
			copy = Alchemy::Element.copy(@element, {:name => 'foobar'})
			copy.name.should == 'foobar'
		end

		it "should make copies of all contents of source" do
			copy = Alchemy::Element.copy(@element)
			copy.contents.collect(&:id).should_not == @element.contents.collect(&:id)
		end

	end

end
