require 'spec_helper'
require 'ostruct'

module Alchemy
  describe Content do
    let(:element) { FactoryGirl.create(:element, name: 'headline', :create_contents_after_create => true) }
    let(:content) { element.contents.find_by_essence_type('Alchemy::EssenceText') }

    it "should return the ingredient from its essence" do
      content.essence.update_attributes(:body => "Hello")
      content.ingredient.should == "Hello"
    end

    describe '.normalize_essence_type' do
      context "passing namespaced essence type" do
        it "should not add alchemy namespace" do
          Content.normalize_essence_type('Alchemy::EssenceText').should == "Alchemy::EssenceText"
        end
      end

      context "passing not namespaced essence type" do
        it "should add alchemy namespace" do
          Content.normalize_essence_type('EssenceText').should == "Alchemy::EssenceText"
        end
      end
    end

    describe '#normalized_essence_type' do
      context "without namespace in essence_type column" do
        it "should return the namespaced essence type" do
          Content.new(:essence_type => 'EssenceText').normalized_essence_type.should == 'Alchemy::EssenceText'
        end
      end

      context "with namespace in essence_type column" do
        it "should return the namespaced essence type" do
          Content.new(:essence_type => 'Alchemy::EssenceText').normalized_essence_type.should == 'Alchemy::EssenceText'
        end
      end
    end

    describe '#update_essence' do
      it "should update the attributes of related essence and return true" do
        @element = FactoryGirl.create(:element, :name => 'text', :create_contents_after_create => true)
        @content = @element.contents.first
        @content.update_essence(:body => 'Mikes Petshop')
        @content.ingredient.should == "Mikes Petshop"
      end

      it "should add error messages if save fails and return false" do
        @element = FactoryGirl.create(:element, :name => 'contactform', :create_contents_after_create => true)
        @content = @element.contents.first
        @content.update_essence
        @content.errors[:essence].should have(1).item
      end

      it "should raise error if essence is missing" do
        @element = FactoryGirl.create(:element, :name => 'text', :create_contents_after_create => true)
        @content = @element.contents.first
        @content.update_essence
      end
    end

    describe '.copy' do
      before(:each) do
        @element = FactoryGirl.create(:element, :name => 'text', :create_contents_after_create => true)
        @content = @element.contents.first
      end

      it "should create a new record with all attributes of source except given differences" do
        copy = Content.copy(@content, {:name => 'foobar', :element_id => @element.id + 1})
        copy.name.should == 'foobar'
      end

      it "should make a new record for essence of source" do
        copy = Content.copy(@content, {:element_id => @element.id + 1})
        copy.essence_id.should_not == @content.essence_id
      end

      it "should copy source essence attributes" do
        copy = Content.copy(@content, {:element_id => @element.id + 1})
        copy.essence.body == @content.essence.body
      end
    end

    describe '.build' do
      let(:element) { FactoryGirl.build_stubbed(:element) }

      it "builds a new instance from elements.yml description" do
        Content.build(element, {name: 'headline'}).should be_instance_of(Content)
      end
    end

    describe '.content_description' do
      let(:element) { FactoryGirl.build_stubbed(:element) }

      context "with blank name key" do
        it "returns a essence hash build from essence type" do
          Content.should_receive(:content_description_from_essence_type).with(element, 'EssenceText')
          Content.content_description(element, essence_type: 'EssenceText')
        end
      end

      context "with name key present" do
        it "returns a essence hash from element" do
          Content.should_receive(:content_description_from_element).with(element, 'headline')
          Content.content_description(element, name: 'headline')
        end
      end
    end

    describe '.content_description_from_element' do
      let(:element) { FactoryGirl.build_stubbed(:element) }
      let(:essence) { {name: 'headline', type: 'EssenceText'} }

      it "returns the description hash from element" do
        element.should_receive(:content_description_for).and_return(essence)
        Content.content_description(element, name: 'headline').should == essence
      end

      context "with content description not found" do
        before {
          element.should_receive(:content_description_for).and_return(nil)
          element.should_receive(:available_content_description_for).and_return(essence)
        }

        it "returns the description hash from available contents" do
          Content.content_description(element, name: 'headline').should == essence
        end
      end
    end

    describe '.content_description_from_essence_type' do
      let(:element) { FactoryGirl.build_stubbed(:element) }

      it "returns the description hash from element" do
        Content.should_receive(:content_name_from_element_and_essence_type).with(element, 'EssenceText').and_return('Foo')
        Content.content_description_from_essence_type(element, 'EssenceText').should == {
          'type' => 'EssenceText',
          'name' => 'Foo'
        }
      end
    end

    describe '.content_name_from_element_and_essence_type' do
      let(:element) { FactoryGirl.build_stubbed(:element) }

      it "returns a name from essence type and count of essences in element" do
        Content.content_name_from_element_and_essence_type(element, 'EssenceText').should == "essence_text_1"
      end
    end

    describe '.create_from_scratch' do
      let(:element) { FactoryGirl.create(:element, name: 'article') }

      it "builds the content" do
        expect(Content.create_from_scratch(element, name: 'headline')).to be_instance_of(Alchemy::Content)
      end

      it "creates the essence from name" do
        expect(Content.create_from_scratch(element, name: 'headline').essence).to_not be_nil
      end

      it "creates the essence from essence_type" do
        expect(Content.create_from_scratch(element, essence_type: 'EssenceText').essence).to_not be_nil
      end

      context "with default value present" do
        it "should have the ingredient column filled with default value." do
          Content.stub(:content_description_from_element).and_return({'name' => 'headline', 'type' => 'EssenceText', 'default' => 'Welcome'})
          content = Content.create_from_scratch(element, name: 'headline')
          content.ingredient.should == "Welcome"
        end
      end
    end

    describe '#ingredient=' do
      it "should set the given value to the ingredient column of essence" do
        c = Content.create_from_scratch(element, name: 'headline')
        c.ingredient = "Welcome"
        c.ingredient.should == "Welcome"
      end

      context "no essence associated" do
        let (:element) { FactoryGirl.create(:element, name: 'headline') }

        it "should raise error" do
          c = Content.create(:element_id => element.id, name: 'headline')
          expect { c.ingredient = "Welcome" }.to raise_error
        end
      end
    end

    describe "#descriptions" do
      context "without any descriptions in elements.yml file" do
        before { Element.stub(:descriptions).and_return([]) }

        it "should return an empty array" do
          Content.descriptions.should == []
        end
      end
    end

    describe '#preview_text' do
      let(:essence) { mock_model(EssenceText, preview_text: 'Lorem') }
      let(:content) { c = Content.new; c.essence = essence; c }

      it "should return the essences preview_text" do
        essence.should_receive(:preview_text).with(30)
        content.preview_text
      end
    end

    describe '#tinymce_class_name' do
      let(:element) { FactoryGirl.build_stubbed(:element, name: 'article') }
      let(:content) { c = Content.new(name: 'text'); c.element = element; c }
      subject { content.tinymce_class_name }

      it { eq('default_tinymce') }

      context 'having custom tinymce config' do
        before { content.stub(:has_custom_tinymce_config?).and_return(true) }
        it('returns name including element name') { eq('custom_tinymce article-text') }
      end
    end

  end
end
