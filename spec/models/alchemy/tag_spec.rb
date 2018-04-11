# frozen_string_literal: true

require 'spec_helper'

module Alchemy
  describe Tag do
    describe '.replace' do
      let(:picture) { Picture.new }
      let(:element) { Element.new }
      let(:tag)     { Tag.new(name: 'red') }
      let(:new_tag) { Tag.new(name: 'green') }

      before do
        allow(picture).to receive(:tag_list).and_return(['red'])
        allow(element).to receive(:tag_list).and_return(['red'])
        allow(picture).to receive(:save).and_return(true)
        allow(element).to receive(:save).and_return(true)
        allow(tag).to receive(:taggings).and_return([
          mock_model(Gutentag::Tagging, taggable: picture),
          mock_model(Gutentag::Tagging, taggable: element)
        ])
      end

      it "should replace given tag with new one on all models tagged with tag" do
        Tag.replace(tag, new_tag)
        expect(picture.tag_list).to eq(['green'])
        expect(element.tag_list).to eq(['green'])
      end
    end
  end
end
