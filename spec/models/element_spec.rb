require 'spec_helper'

describe Alchemy::Element do

  context "scoped" do

    before(:each) do
      Alchemy::Element.delete_all
    end

    it "should return all public elements" do
      elements = [FactoryGirl.create(:element, :public => true), FactoryGirl.create(:element, :public => true)]
      Alchemy::Element.published.all.should == elements
    end

    it "should return all elements by name" do
      elements = [FactoryGirl.create(:element, :name => 'article'), FactoryGirl.create(:element, :name => 'article')]
      Alchemy::Element.named(['article']).all.should == elements
    end

    it "should return all elements but excluded ones" do
      FactoryGirl.create(:element, :name => 'article')
      FactoryGirl.create(:element, :name => 'article')
      excluded = [FactoryGirl.create(:element, :name => 'claim')]
      Alchemy::Element.excluded(['article']).all.should == excluded
    end

    context "not_in_cell" do
      it "should return all elements that are not in a cell" do
        FactoryGirl.create(:element, :cell_id => 6)
        FactoryGirl.create(:element, :cell_id => nil)
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

  context "no description files are found" do

    before(:each) do
      FileUtils.mv(File.join(File.dirname(__FILE__), '..', '..', 'config', 'alchemy', 'elements.yml'), File.join(File.dirname(__FILE__), '..', '..', 'config', 'alchemy', 'elements.yml.bak'))
    end

    it "should raise an error" do
      expect { Alchemy::Element.descriptions }.should raise_error
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
    @element = FactoryGirl.create(:element)
    @element.trash
    Alchemy::Element.trashed.should include(@element)
  end

  it "should return a collection of not trashed elements" do
    @element = FactoryGirl.create(:element, :page_id => 1)
    Alchemy::Element.not_trashed.should include(@element)
  end

  context "limited amount" do
    before(:each) do
      descriptions = Alchemy::Element.descriptions
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
      Alchemy::Element.stub!(:descriptions).and_return(descriptions)
      Alchemy::PageLayout.add(
        'name' => 'columns',
        'elements' => ['column_headline', 'unique_headline'],
        'autogenerate' => ['unique_headline', 'column_headline', 'column_headline', 'column_headline']
      )
      @page = FactoryGirl.create(:page, :page_layout => 'columns')
    end

    it "should be readable" do
      element = Alchemy::Element.all_definitions_for(['column_headline']).first
      element['amount'].should be 3
    end

    it "should limit elements" do
      Alchemy::Element.all_for_page(@page).each { |e| e['name'].should_not == 'column_headline' }
    end

    it "should be ignored if unique" do
      Alchemy::Element.all_for_page(@page).each { |e| e['name'].should_not == 'unique_headline' }
    end

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
    expect { Alchemy::Element.all_for_page(nil) }.should raise_error(TypeError)
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
