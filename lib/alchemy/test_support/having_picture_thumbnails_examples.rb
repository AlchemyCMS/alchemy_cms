# frozen_string_literal: true

RSpec.shared_examples_for "having picture thumbnails" do
  it "should not store negative values for crop values" do
    record.crop_from = "-1x100"
    record.crop_size = "-20x30"
    record.save
    expect(record.crop_from).to eq("0x100")
    expect(record.crop_size).to eq("0x30")
  end

  it "should not store float values for crop values" do
    record.crop_from = "0.05x104.5"
    record.crop_size = "99.5x203.4"
    record.save
    expect(record.crop_from).to eq("0x105")
    expect(record.crop_size).to eq("100x203")
  end

  it "should not store empty strings for nil crop values" do
    record.crop_from = nil
    record.crop_size = nil
    record.save
    expect(record.crop_from).to eq(nil)
    expect(record.crop_size).to eq(nil)
  end

  describe "#picture_url" do
    subject(:picture_url) { record.picture_url(options) }

    let(:options) { {} }
    let(:picture) { create(:alchemy_picture) }

    context "with no format in the options" do
      it "includes the image's default render format." do
        expect(picture_url).to match(/\.png/)
      end
    end

    context "with format in the options" do
      let(:options) { { format: "gif" } }

      it "takes this as format." do
        expect(picture_url).to match(/\.gif/)
      end
    end

    context "when crop values are present" do
      before do
        allow(record).to receive(:crop_from) { "10x10" }
        allow(record).to receive(:crop_size) { "200x200" }
      end

      context "if cropping is enabled" do
        before do
          allow(record).to receive(:settings) { { crop: true } }
        end

        it "passes these crop values to the picture's url method." do
          expect(picture).to receive(:url).with(
            hash_including(crop_from: "10x10", crop_size: "200x200"),
          )
          picture_url
        end

        context "but with crop values in the options" do
          let(:options) do
            { crop_from: "30x30", crop_size: "75x75" }
          end

          it "passes these crop values instead." do
            expect(picture).to receive(:url).with(
              hash_including(crop_from: "30x30", crop_size: "75x75"),
            )
            picture_url
          end
        end
      end
    end

    context "with other options" do
      let(:options) { { foo: "baz" } }

      context "and the image does not need to be processed" do
        before do
          allow(record).to receive(:settings) { {} }
        end

        it "adds them to the url" do
          expect(picture_url).to match(/\?foo=baz/)
        end
      end
    end

    context "without picture assigned" do
      let(:picture) { nil }

      it { is_expected.to be_nil }
    end

    context "if picture.url returns nil" do
      before do
        expect(picture).to receive(:url) { nil }
      end

      it "returns missing image url" do
        is_expected.to eq "missing-image.png"
      end
    end
  end

  describe "#picture_url_options" do
    subject(:picture_url_options) { record.picture_url_options }

    let(:picture) { build_stubbed(:alchemy_picture) }

    it { is_expected.to be_a(HashWithIndifferentAccess) }

    it "includes the pictures default render format." do
      expect(picture).to receive(:default_render_format) { "img" }
      expect(picture_url_options[:format]).to eq("img")
    end

    context "with crop values present" do
      before do
        allow(record).to receive(:crop_from) { "10x10" }
        allow(record).to receive(:crop_size) { "200x200" }
      end

      context "with cropping enabled" do
        before do
          allow(record).to receive(:settings) { { crop: true } }
        end

        it "includes these crop values.", :aggregate_failures do
          expect(picture_url_options[:crop_from]).to eq "10x10"
          expect(picture_url_options[:crop_size]).to eq "200x200"
        end
      end

      context "with cropping disabled" do
        before do
          allow(record).to receive(:settings) { { crop: nil } }
        end

        it "does not include these crop values.", :aggregate_failures do
          expect(picture_url_options[:crop_from]).to be_nil
          expect(picture_url_options[:crop_size]).to be_nil
        end
      end

      # Regression spec for issue #1279
      context "with crop values being empty strings" do
        before do
          allow(record).to receive(:crop_from) { "" }
          allow(record).to receive(:crop_size) { "" }
        end

        it "does not include these crop values.", :aggregate_failures do
          expect(picture_url_options[:crop_from]).to be_nil
          expect(picture_url_options[:crop_size]).to be_nil
        end
      end
    end

    context "having size setting" do
      before do
        allow(record).to receive(:settings) { { size: "30x70" } }
      end

      it "includes this size." do
        expect(picture_url_options[:size]).to eq "30x70"
      end
    end

    context "having crop setting" do
      before do
        allow(record).to receive(:settings) { { crop: true } }
      end

      it "includes this setting" do
        expect(picture_url_options[:crop]).to be true
      end
    end

    context "without picture assigned" do
      let(:picture) { nil }

      it { is_expected.to be_a(Hash) }
    end
  end

  describe "#thumbnail_url" do
    subject(:thumbnail_url) { record.thumbnail_url }

    let(:settings) do
      {}
    end

    let(:picture) { create(:alchemy_picture) }

    before do
      allow(record).to receive(:settings) { settings }
    end

    it "includes the image's original file format." do
      expect(thumbnail_url).to match(/\.png/)
    end

    it "flattens the image." do
      expect(picture).to receive(:url).with(hash_including(flatten: true))
      thumbnail_url
    end

    context "when crop is enabled in the settings" do
      let(:settings) do
        { crop: true }
      end

      context "and crop sizes are present" do
        before do
          allow(record).to receive(:crop_size).and_return("200x200")
          allow(record).to receive(:crop_from).and_return("10x10")
        end

        it "passes these crop sizes to the picture's url method." do
          expect(picture).to receive(:url).with(
            hash_including(
              crop_from: "10x10",
              crop_size: "200x200",
              crop: true,
            ),
          )
          thumbnail_url
        end
      end

      context "when no crop sizes are present" do
        it "it does not pass crop sizes to the picture's url method and enables center cropping." do
          expect(picture).to receive(:url).with(
            hash_including(
              crop_from: nil,
              crop_size: nil,
              crop: true,
            ),
          )
          thumbnail_url
        end
      end
    end

    context "when cropping is disabled in the settings" do
      let(:settings) do
        { crop: false }
      end

      context "but crop sizes are present" do
        before do
          allow(record).to receive(:crop_size).and_return("200x200")
          allow(record).to receive(:crop_from).and_return("10x10")
        end

        it "it disables cropping." do
          expect(picture).to receive(:url).with(
            hash_including(
              crop_size: nil,
              crop_from: nil,
              crop: false,
            ),
          )
          thumbnail_url
        end
      end
    end

    context "without picture assigned" do
      let(:picture) { nil }

      it { is_expected.to be_nil }
    end

    context "if picture.url returns nil" do
      before do
        expect(picture).to receive(:url) { nil }
      end

      it "returns missing image url" do
        is_expected.to eq "alchemy/missing-image.svg"
      end
    end
  end

  describe "#thumbnail_url_options" do
    subject(:thumbnail_url_options) { record.thumbnail_url_options }

    let(:settings) { {} }
    let(:picture) { nil }

    before do
      allow(record).to receive(:settings) { settings }
    end

    context "with picture assigned" do
      let(:picture) do
        create(:alchemy_picture)
      end

      it "includes the image's original file format." do
        expect(thumbnail_url_options[:format]).to eq("png")
      end

      it "flattens the image." do
        expect(thumbnail_url_options[:flatten]).to be(true)
      end
    end

    context "when cropping is enabled in settings" do
      let(:settings) do
        { crop: true }
      end

      context "and crop values are present" do
        before do
          expect(record).to receive(:crop_size).at_least(:once) { "200x200" }
          expect(record).to receive(:crop_from).at_least(:once) { "10x10" }
        end

        it "includes these crop values" do
          expect(thumbnail_url_options).to match(
            hash_including(
              crop_from: "10x10",
              crop_size: "200x200",
              crop: true,
            )
          )
        end
      end

      context "and no crop values are present" do
        it "does not include crop values but enables center cropping" do
          expect(thumbnail_url_options).to match(
            hash_including(
              crop_from: nil,
              crop_size: nil,
              crop: true,
            )
          )
        end
      end
    end

    context "when cropping is disabled in settings" do
      let(:settings) do
        { crop: false }
      end

      context "but crop values are present" do
        before do
          allow(record).to receive(:crop_size) { "200x200" }
          allow(record).to receive(:crop_from) { "10x10" }
        end

        it "does not include crop values" do
          expect(thumbnail_url_options).to match(
            hash_including(
              crop_from: nil,
              crop_size: nil,
              crop: false,
            )
          )
        end
      end
    end

    context "without picture assigned" do
      let(:picture) { nil }

      it "returns default thumbnail options" do
        is_expected.to eq(
          crop: false,
          crop_from: nil,
          crop_size: nil,
          flatten: true,
          format: "jpg",
          size: "160x120",
        )
      end
    end
  end

  describe "#image_cropper_settings" do
    let(:picture) { nil }

    subject { record.image_cropper_settings }

    context "with no picture assigned" do
      it { is_expected.to eq({}) }
    end

    context "with picture assigned" do
      let(:picture) { build_stubbed(:alchemy_picture) }

      let(:default_mask) do
        [
          0,
          0,
          300,
          250,
        ]
      end

      let(:settings) { {} }

      before do
        picture.image_file_width = 300
        picture.image_file_height = 250
        allow(record).to receive(:settings) { settings }
      end

      context "with no render_size present" do
        before do
          expect(record).to receive(:render_size).at_least(:once).and_return(nil)
        end

        context "with sizes in  settings" do
          let(:settings) do
            { size: "300x250" }
          end

          it "sets sizes to given values" do
            expect(subject[:min_size]).to eq([300, 250])
          end
        end

        context "with no sizes in settings" do
          it "sets sizes to zero" do
            expect(subject[:min_size]).to eq([0, 0])
          end
        end
      end

      context "with render_size present in record" do
        it "sets sizes from these values" do
          expect(record).to receive(:render_size).at_least(:once).and_return("30x25")
          expect(subject[:min_size]).to eq([30, 25])
        end

        context "when width or height is not fixed" do
          it "infers the height from the image file preserving the aspect ratio" do
            expect(record).to receive(:render_size).at_least(:once).and_return("30x")
            expect(subject[:min_size]).to eq([30, 25])
          end

          context "and aspect ratio set" do
            let(:settings) do
              { fixed_ratio: "2" }
            end

            it "does not infer the height from the image file preserving the aspect ratio" do
              expect(record).to receive(:render_size).at_least(:once).and_return("x25")
              expect(subject[:min_size]).to eq([50, 25])
            end
          end
        end

        context "when width or height is not fixed and an aspect ratio is given" do
          context "and aspect ratio set" do
            let(:settings) do
              { fixed_ratio: "0.5" }
            end

            it "width is given, it infers the height from width and ratio" do
              expect(record).to receive(:render_size).at_least(:once).and_return("30x")
              expect(subject[:min_size]).to eq([30, 60])
            end
          end

          it "infers the height from the image file preserving the aspect ratio" do
            expect(record).to receive(:render_size).at_least(:once).and_return("x25")
            expect(subject[:min_size]).to eq([30, 25])
          end
        end
      end

      context "no crop sizes present in record" do
        it "assigns default mask boxes" do
          expect(subject[:default_box]).to eq(default_mask)
        end
      end

      context "crop sizes present in record" do
        let(:mask) { [0, 0, 120, 160] }

        before do
          allow(record).to receive(:crop_from).and_return("0x0")
          allow(record).to receive(:crop_size).and_return("120x160")
        end

        it "assigns cropping boxes" do
          expect(subject[:default_box]).to eq(default_mask)
        end
      end

      context "with fixed_ratio set to false" do
        let(:settings) do
          { fixed_ratio: false }
        end

        it "sets ratio to false" do
          expect(subject[:ratio]).to eq(false)
        end
      end

      context "with fixed_ratio set to a non float string" do
        let(:settings) do
          { fixed_ratio: "123,45" }
        end

        it "raises an error" do
          expect { subject }.to raise_exception(ArgumentError)
        end
      end

      context "with no fixed_ratio set" do
        let(:settings) do
          { size: "80x60" }
        end

        it "sets a fixed ratio from sizes" do
          expect(subject[:ratio]).to eq(80.0 / 60.0)
        end
      end

      context "with size set to different values" do
        let(:settings) { { crop: true, size: size } }

        before do
          picture.image_file_width = 200
          picture.image_file_height = 100
        end

        context "size 200x50" do
          let(:size) { "200x50" }

          it "default box should be [0, 25, 200, 75]" do
            expect(subject[:default_box]).to eq([0, 25, 200, 75])
          end
        end

        context "size 0x0" do
          let(:size) { "0x0" }

          it "it should not crop the picture" do
            expect(subject[:default_box]).to eq([0, 0, 200, 100])
          end
        end

        context "size 50x100" do
          let(:size) { "50x100" }

          it "the hash should be {x1: 75, y1: 0, x2: 125, y2: 100}" do
            expect(subject[:default_box]).to eq([75, 0, 125, 100])
          end
        end

        context "size 50x50" do
          let(:size) { "50x50" }

          it "the hash should be {x1: 50, y1: 0, x2: 150, y2: 100}" do
            expect(subject[:default_box]).to eq([50, 0, 150, 100])
          end
        end

        context "size 400x200" do
          let(:size) { "400x200" }

          it "the hash should be {x1: 0, y1: 0, x2: 200, y2: 100}" do
            expect(subject[:default_box]).to eq([0, 0, 200, 100])
          end
        end

        context "size 400x100" do
          let(:size) { "400x100" }

          it "the hash should be {x1: 0, y1: 25, x2: 200, y2: 75}" do
            expect(subject[:default_box]).to eq([0, 25, 200, 75])
          end
        end

        context "size 200x200" do
          let(:size) { "200x200" }

          it "the hash should be {x1: 50, y1: 0, x2: 150, y2: 100}" do
            expect(subject[:default_box]).to eq([50, 0, 150, 100])
          end
        end
      end
    end
  end

  describe "#allow_image_cropping?" do
    let(:picture) do
      stub_model(Alchemy::Picture, image_file_width: 400, image_file_height: 300)
    end

    subject { record.allow_image_cropping? }

    it { is_expected.to be_falsy }

    context "with picture assigned" do
      before do
        allow(record).to receive(:picture) { picture }
      end

      it { is_expected.to be_falsy }

      context "and with image larger than crop size" do
        before do
          allow(picture).to receive(:can_be_cropped_to?) { true }
        end

        it { is_expected.to be_falsy }

        context "with crop set to true" do
          before do
            allow(record).to receive(:settings) { { crop: true } }
          end

          context "if picture.image_file is nil" do
            before do
              expect(picture).to receive(:image_file) { nil }
            end

            it { is_expected.to be_falsy }
          end

          context "if picture.image_file is present" do
            let(:picture) { build_stubbed(:alchemy_picture) }

            it { is_expected.to be(true) }
          end
        end
      end
    end
  end
end
