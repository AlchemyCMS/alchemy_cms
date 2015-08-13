require 'spec_helper'

describe Alchemy::Admin::PictureStylesHelper do

  let(:essence)       { FactoryGirl.create :essence_picture }
  let(:picture_style) { essence.picture_style }
  let!(:content)      { create(:content, essence: essence) }

  describe '#picture_thumbnail' do

    it "should return an image tag" do
      expect(helper.picture_thumbnail(picture_style, {})).to have_selector('img[src]')
    end

    context 'when the picture given has a size of 140x169 and it should be cropped to 250x250' do
      before do
        allow(picture_style).to receive(:image_file_width).and_return(140)
        allow(picture_style).to receive(:image_file_height).and_return(169)
      end

      it 'the thumbnail url should contain 77 and 93 as thumbnail width and height' do
        expect(helper.picture_thumbnail(picture_style, {image_size: "250x250", crop: true})).to match(/77x93/)
      end

      it 'the thumbnail url should contain 77 and 93 as thumbnail width and height' do
        expect(helper.picture_thumbnail(picture_style, {image_size: "250x250"})).to match(/77x93/)
      end
    end

    context 'when the picture given has a size of 300x50 and it should be cropped/resized to 225x175' do
      before do
        allow(picture_style).to receive(:image_file_width).and_return(300)
        allow(picture_style).to receive(:image_file_height).and_return(50)
      end

      it 'the thumbnail url should contain 111x25 as thumbnail width and height' do
        expect(helper.picture_thumbnail(picture_style, { size: '225x175', crop: true })).to match(/111x25/)
      end

      it 'the thumbnail url should contain 111x19 as thumbnail width and height' do
        expect(helper.picture_thumbnail(picture_style, { size: '225x175' })).to match(/111x19/)
      end
    end
  end

end
