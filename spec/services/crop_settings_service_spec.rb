require 'spec_helper'

describe Alchemy::Admin::CropSettingsService do
  let(:picture)       { create :picture, image_file_width: 300, image_file_height: 250 }
  let(:essence)       { create :essence_picture, picture: picture }
  let(:picture_style) { essence.picture_style }
  let(:options)       { {} }
  let(:crop_settings) { Alchemy::Admin::CropSettingsService.new(picture_style, options)}
  let(:default_mask)  { { x1: 0, y1: 0, x2: 300, y2: 250 } }

  context 'with dimensions in options' do
    let(:options) { { image_size: '300x250' } }

    it "sets dimensions to given values" do
      expect(crop_settings.dimensions).to eq({ width: 300, height: 250 })
    end
  end

  context 'with no dimensions in params' do
    it "sets dimensions to zero" do
      expect(crop_settings.dimensions).to eq({ width: 0, height: 0 })
    end
  end

  context 'with render_size present in picture_style' do
    it "sets sizes from these values" do
      picture_style.render_size = '30x25'
      expect(crop_settings.dimensions).to eq({ width: 30, height: 25 })
    end

    context 'when width or height is missing and aspect ratio is given' do
      let(:options) { { fixed_ratio: '2' } }

      it 'infers the height preserving the aspect ratio' do
        picture_style.render_size = '50x'
        expect(crop_settings.dimensions).to eq({ width: 50, height: 25})
      end

      it 'infers the width preserving the aspect ratio' do
        picture_style.render_size = 'x25'
        expect(crop_settings.dimensions).to eq({ width: 50, height: 25})
      end
    end

    context 'when width or height is missing and no aspect ratio is given' do
      it 'infers the height preserving the aspect ratio' do
        picture_style.render_size = '50x'
        expect(crop_settings.dimensions).to eq({ width: 50, height: 0})
      end

      it 'infers the width preserving the aspect ratio' do
        picture_style.render_size = 'x25'
        expect(crop_settings.dimensions).to eq({ width: 0, height: 25})
      end
    end
  end

  context 'no crop sizes present in picture_style' do
    it "assigns default mask boxes" do
      expect(crop_settings.initial_box).to eq(default_mask)
      expect(crop_settings.default_box).to eq(default_mask)
    end
  end

  context 'crop sizes present in picture_style' do
    let(:mask) { { x1: 0, y1: 0, x2: 120, y2: 160 } }

    before do
      picture_style.crop_from = '0x0'
      picture_style.crop_size = '120x160'
      expect(picture_style.cropping_mask).to eq(mask)
    end

    it "assigns cropping boxes" do
      expect(crop_settings.initial_box).to eq(mask)
      expect(crop_settings.default_box).to eq(default_mask)
    end
  end

  context 'with fixed_ratio set to false' do
    let(:options) { { fixed_ratio: false } }

    it "sets ratio to false" do
      expect(crop_settings.ratio).to eq(false)
    end
  end

  context 'with no fixed_ratio set in params' do
    let(:options) { { image_size: '80x60' } }

    it "sets a fixed ratio from sizes" do
      expect(crop_settings.ratio).to eq(80.0/60.0)
    end
  end
end
