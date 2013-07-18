require 'spec_helper'

module Alchemy
  describe Tag do

    describe '.replace' do
      let(:picture) { Picture.new }
      let(:element) { Element.new }
      let(:tag)     { Tag.new(name: 'red') }
      let(:new_tag) { Tag.new(name: 'green') }

      before do
        picture.stub(:tag_list).and_return(['red'])
        element.stub(:tag_list).and_return(['red'])
        picture.stub(:save).and_return(true)
        element.stub(:save).and_return(true)
        tag.stub(:taggings).and_return([
          mock_model(ActsAsTaggableOn::Tagging, taggable: picture),
          mock_model(ActsAsTaggableOn::Tagging, taggable: element)
        ])
      end

      it "should replace given tag with new one on all models tagged with tag" do
        Tag.replace(tag, new_tag)
        picture.tag_list.should eq(['green'])
        element.tag_list.should eq(['green'])
      end
    end

  end
end