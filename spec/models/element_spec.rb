require 'spec_helper'

module Alchemy
  describe Element do

    context "scoped" do

      it "should return all public elements" do
        element_1 = FactoryGirl.create(:element, :public => true)
        element_2 = FactoryGirl.create(:element, :public => true)
        elements = Element.published.all
        elements.should include(element_1)
        elements.should include(element_2)
      end

      it "should return all elements by name" do
        element_1 = FactoryGirl.create(:element, :name => 'article')
        element_2 = FactoryGirl.create(:element, :name => 'article')
        elements = Element.named(['article']).all
        elements.should include(element_1)
        elements.should include(element_2)
      end

      it "should return all elements but excluded ones" do
        FactoryGirl.create(:element, :name => 'article')
        FactoryGirl.create(:element, :name => 'article')
        excluded = FactoryGirl.create(:element, :name => 'claim')
        Element.excluded(['claim']).all.should_not include(excluded)
      end

      context "not_in_cell" do

        it "should return all elements that are not in a cell" do
          Element.delete_all
          FactoryGirl.create(:element, :cell_id => 6)
          FactoryGirl.create(:element, :cell_id => nil)
          Element.not_in_cell.should have(1).element
        end

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

    context "no description files are found" do

      before(:each) do
        FileUtils.mv(File.join(File.dirname(__FILE__), '..', '..', 'config', 'alchemy', 'elements.yml'), File.join(File.dirname(__FILE__), '..', '..', 'config', 'alchemy', 'elements.yml.bak'))
      end

      it "should raise an error" do
        expect { Element.descriptions }.to raise_error(LoadError)
      end

      after(:each) do
        FileUtils.mv(File.join(File.dirname(__FILE__), '..', '..', 'config', 'alchemy', 'elements.yml.bak'), File.join(File.dirname(__FILE__), '..', '..', 'config', 'alchemy', 'elements.yml'))
      end

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

    context "limited amount" do
      before(:each) do
        descriptions = Element.descriptions
        descriptions << {
          'name' => 'column_headline',
          'amount' => 3,
          'contents' => [{'name' => 'headline', 'type' => 'EssenceText'}]
        }
        descriptions << {
          'name' => 'unique_headline',
          'unique' => true,
          'amount' => 3,
          'contents' => [{'name' => 'headline', 'type' => 'EssenceText'}]
        }
        Element.stub!(:descriptions).and_return(descriptions)
        PageLayout.add(
          'name' => 'columns',
          'elements' => ['column_headline', 'unique_headline'],
          'autogenerate' => ['unique_headline', 'column_headline', 'column_headline', 'column_headline']
        )
        @page = FactoryGirl.create(:page, :page_layout => 'columns')
      end

      it "should be readable" do
        element = Element.all_definitions_for(['column_headline']).first
        element['amount'].should be 3
      end

      it "should limit elements" do
        Element.all_for_page(@page).each { |e| e['name'].should_not == 'column_headline' }
      end

      it "should be ignored if unique" do
        Element.all_for_page(@page).each { |e| e['name'].should_not == 'unique_headline' }
      end

    end

    context "collections" do
      context "for trashed elements" do

        let(:element) do
          FactoryGirl.create(:element, :page_id => 1)
        end

        it "should return a collection of trashed elements" do
          not_trashed_element = FactoryGirl.create(:element)
          element.trash
          Element.trashed.should include(element)
        end

        it "should return a collection of not trashed elements" do
          Element.not_trashed.should include(element)
        end

      end
    end

    describe "#trash" do

      before(:each) do
        @element = FactoryGirl.create(:element, :page_id => 1, :cell_id => 1)
        @element.trash
      end

      it "should remove the elements position" do
        @element.position.should == nil
      end

      it "should set the public state to false" do
        @element.public?.should == false
      end

      it "should not remove the page_id" do
        @element.page_id.should == 1
      end

      it "should not remove the cell_id" do
        @element.cell_id.should == 1
      end

      it "it should be possible to trash more than one element from the same page" do
        trashed_element_2 = FactoryGirl.create(:element, :page_id => 1)
        trashed_element_2.trash
        Element.trashed.should include(@element, trashed_element_2)
      end

    end

    it "should raise error if all_for_page method has no page" do
      expect { Element.all_for_page(nil) }.to raise_error(TypeError)
    end

    describe "#content_by_type" do

      before(:each) do
        @element = FactoryGirl.create(:element, :name => 'headline')
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
        @element = FactoryGirl.create(:element)
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
        @element = FactoryGirl.create(:element)
      end

      it "should not create contents from scratch" do
        copy = Element.copy(@element)
        copy.contents.count.should == @element.contents.count
      end

      it "should create a new record with all attributes of source except given differences" do
        copy = Element.copy(@element, {:name => 'foobar'})
        copy.name.should == 'foobar'
      end

      it "should make copies of all contents of source" do
        copy = Element.copy(@element)
        copy.contents.collect(&:id).should_not == @element.contents.collect(&:id)
      end

    end

    describe "Finding previous or next element." do

      before(:each) do
        @page = FactoryGirl.create(:language_root_page)
        @page.elements.delete_all
        @element1 = FactoryGirl.create(:element, :page => @page, :name => 'headline')
        @element2 = FactoryGirl.create(:element, :page => @page)
        @element3 = FactoryGirl.create(:element, :page => @page, :name => 'text')
      end

      describe '#prev' do

        it "should return previous element on same page" do
          @element2.prev.should == @element1
        end

        context "with name as parameter" do
          it "should return previous of this kind" do
            @element3.prev('headline').should == @element1
          end
        end

      end

      describe '#next' do

        it "should return next element on same page" do
          @element1.next.should == @element2
        end

        context "with name as parameter" do
          it "should return next of this kind" do
            @element1.next('text').should == @element3
          end
        end

      end

    end

  end
end
