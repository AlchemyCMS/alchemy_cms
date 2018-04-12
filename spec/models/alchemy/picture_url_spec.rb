# frozen_string_literal: true

require 'spec_helper'

module Alchemy
  describe "Picture::Url" do
    include ActionDispatch::TestProcess

    # Helper to dedoce a hashed dragonfly job
    def decode_dragon_fly_job(url)
      job = url.split('/')[2]
      Dragonfly::Serializer.json_b64_decode(job)
    end

    let(:image) do
      fixture_file_upload(
        File.expand_path('../../fixtures/500x500.png', __dir__),
        'image/png'
      )
    end

    let(:picture) do
      create(:alchemy_picture, image_file: image)
    end

    describe "#url" do
      subject(:url) { picture.url(options) }

      let(:options) { Hash.new }

      it 'includes the name and render format' do
        expect(url).to match /\/#{picture.name}\.#{picture.default_render_format}/
      end

      context "when no image is present" do
        before do
          expect(picture).to receive(:image_file) { nil }
        end

        it 'returns nil' do
          expect(url).to be_nil
        end

        it "logs warning" do
          expect(Alchemy::Logger).to receive(:warn)
          url
        end
      end

      context "when a size is passed in" do
        let(:options) do
          {size: '120x160'}
        end

        it 'resizes the image without upsampling it' do
          job = decode_dragon_fly_job(url)
          expect(job[1]).to include("120x160>")
        end

        context "but upsample set to true" do
          let(:options) do
            {
              size: '1600x1200',
              upsample: true
            }
          end

          it "resizes the image with upsampling it" do
            job = decode_dragon_fly_job(url)
            expect(job[1]).to include("1600x1200")
          end
        end

        context "and crop is set to true" do
          let(:options) do
            {
              size: '160x120',
              crop: true
            }
          end

          it "crops from center and resizes the picture" do
            job = decode_dragon_fly_job(url)
            expect(job[1]).to include("160x120#")
          end

          context "and crop_from and crop_size is passed in" do
            let(:options) do
              {
                crop_size: '123x44',
                crop_from: '0x0',
                size: '160x120',
                crop: true
              }
            end

            it "crops and resizes the picture" do
              job = decode_dragon_fly_job(url)
              expect(job[1]).to include("-crop 123x44+0+0 -resize 160x120>")
            end
          end
        end

        context "and crop is set to false" do
          let(:options) do
            {
              size: '160x120',
              crop: false
            }
          end

          it "does not crop the picture" do
            job = decode_dragon_fly_job(url)
            expect(job[1]).to_not include("160x120#")
          end

          context "and crop_from and crop_size is passed in" do
            let(:options) do
              {
                crop_size: '123x44',
                crop_from: '0x0',
                size: '160x120',
                crop: false
              }
            end

            it "does not crop the picture" do
              job = decode_dragon_fly_job(url)
              expect(job[1]).to_not include("-crop 123x44+0+0")
            end
          end
        end

        context "with no height given" do
          let(:options) do
            {size: '40'}
          end

          it "resizes the image inferring the height" do
            job = decode_dragon_fly_job(url)
            expect(job[1]).to include("40>")
          end
        end

        context "with no width given" do
          let(:options) do
            {size: 'x30'}
          end

          it "resizes the image inferring the width" do
            job = decode_dragon_fly_job(url)
            expect(job[1]).to include("x30>")
          end
        end
      end

      context "when no size is passed in" do
        it 'does not resize the image' do
          # only the fetch step should be present
          expect(decode_dragon_fly_job(url).size).to eq(1)
        end
      end

      context "when a different format is requested" do
        let(:options) do
          {format: 'gif'}
        end

        it 'converts the format' do
          job = decode_dragon_fly_job(url)
          expect(job[1]).to include("encode", "gif")
        end

        context "but image has not a convertible format (svg)" do
          let(:image) do
            fixture_file_upload(
              File.expand_path('../../fixtures/icon.svg', __dir__),
              'image/svg+xml'
            )
          end

          it 'does not convert the picture format' do
            # only the fetch step should be present
            expect(decode_dragon_fly_job(url).size).to eq(1)
          end
        end

        context 'for an animated gif' do
          let(:options) do
            {format: 'png'}
          end

          let(:image) do
            fixture_file_upload(
              File.expand_path('../../fixtures/animated.gif', __dir__),
              'image/gif'
            )
          end

          it 'flattens the image.' do
            job = decode_dragon_fly_job(url)
            expect(job[1]).to include("-flatten")
          end
        end
      end

      context "requesting a not allowed format" do
        let(:options) do
          {format: 'zip'}
        end

        it "returns nil" do
          expect(url).to be_nil
        end

        it "logs warning" do
          expect(Alchemy::Logger).to receive(:warn)
          url
        end
      end

      context "when jpg format is requested" do
        let(:options) do
          {format: 'jpg'}
        end

        it 'sets the default quality' do
          job = decode_dragon_fly_job(url)
          expect(job[1]).to include("-quality 85")
        end

        context "and quality is passed" do
          let(:options) do
            {format: 'jpg', quality: '30'}
          end

          it 'sets the quality' do
            job = decode_dragon_fly_job(url)
            expect(job[1]).to include("-quality 30")
          end
        end
      end
    end
  end
end
