require 'spec_helper'

module Alchemy
  describe EssencePicture do
    it_behaves_like "an essence" do
      let(:essence)          { EssencePicture.new }
      let(:ingredient_value) { Picture.new }
    end

    it "should convert newlines in caption into <br/>s" do
      essence = EssencePicture.new(:caption => "hello\nkitty")
      essence.save!
      expect(essence.caption).to eq("hello<br/>kitty")
    end

    describe '#preview_text' do
      let(:picture) { mock_model(Picture, name: 'Cute Cat Kittens')}
      let(:essence) { EssencePicture.new }

      it "should return the pictures name as preview text" do
        allow(essence).to receive(:picture).and_return(picture)
        expect(essence.preview_text).to eq('Cute Cat Kittens')
      end

      context "with no picture assigned" do
        it "returns empty string" do
          expect(essence.preview_text).to eq('')
        end
      end
    end

    describe '#serialized_ingredient' do
      let!(:content) { create(:content, name: 'image', essence_type: 'EssencePicture', essence: essence) }
      let(:essence) { create(:essence_picture) }
      let(:picture) { essence.picture }


      it "returns the url to render the picture" do
        expect(essence.serialized_ingredient).to eq("/pictures/#{picture.id}/show/#{picture.urlname}.jpg?sh=#{picture.security_token}")
      end

      context 'with image settings given at content' do
        before do
          expect(essence.content).to receive(:settings).and_return({size: '150x150', format: 'png', select_values: [1,2,3]})
        end

        it "returns the url with cropping and resizing options" do
          security_token = picture.security_token({size: '150x150', format: 'png'})
          expect(essence.serialized_ingredient).to eq("/pictures/#{picture.id}/show/150x150/#{picture.urlname}.png?sh=#{security_token}")
        end

        it "rejects options that are not cropping and resizing options" do
          expect(essence.serialized_ingredient).to_not match("select_values")
        end
      end
    end

    describe "#allow_image_cropping?" do
      let(:essence_picture) { stub_model(Alchemy::EssencePicture) }
      let(:content) { stub_model(Alchemy::Content) }
      let(:picture) { stub_model(Alchemy::Picture) }

      subject { essence_picture.allow_image_cropping? }

      it { is_expected.to be_falsy }

      context "with content existing?" do
        before do
          allow(essence_picture).to receive(:content) { content }
        end

        it { is_expected.to be_falsy }

        context "with picture assigned" do
          before do
            allow(essence_picture).to receive(:picture) { picture }
          end

          it { is_expected.to be_falsy }

          context "and with image larger than crop size" do
            before do
              allow(picture).to receive(:can_be_cropped_to) { true }
            end

            it { is_expected.to be_falsy }

            context "with crop set to true" do
              before do
                allow(content).to receive(:settings_value) { true }
              end

              it { is_expected.to be(true) }
            end
          end
        end
      end
    end
  end
end
