# frozen_string_literal: true

RSpec.shared_examples_for "having crop action" do |args|
  describe "#crop" do
    let(:picture) { Alchemy::Picture.new }

    before do
      expect(args[:model_class]).to receive(:find).and_return(croppable_resource)
    end

    context "with no picture assigned" do
      it "renders error message" do
        get :crop, params: { id: 1 }
        expect(assigns(:no_image_notice)).to eq(Alchemy.t(:no_image_for_cropper_found))
      end
    end

    context "with picture assigned" do
      subject { get :crop, params: { id: 1, picture_id: picture.id } }

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
        allow(croppable_resource).to receive(:settings) { settings }
        expect(Alchemy::Picture).to receive(:find_by) { picture }
      end

      context "with no render_size present in croppable_resource" do
        before do
          expect(croppable_resource).to receive(:render_size).at_least(:once).and_return(nil)
        end

        context "with sizes in settings" do
          let(:settings) do
            { size: "300x250" }
          end

          it "sets sizes to given values" do
            subject
            expect(assigns(:settings)[:min_size]).to eq([300, 250])
          end
        end

        context "with no sizes in settings" do
          it "sets sizes to zero" do
            subject
            expect(assigns(:settings)[:min_size]).to eq([0, 0])
          end
        end
      end

      context "with render_size present in croppable_resource" do
        it "sets sizes from these values" do
          expect(croppable_resource).to receive(:render_size).at_least(:once).and_return("30x25")

          subject
          expect(assigns(:settings)[:min_size]).to eq([30, 25])
        end

        context "when width or height is not fixed" do
          it "infers the height from the image file preserving the aspect ratio" do
            expect(croppable_resource).to receive(:render_size).at_least(:once).and_return("30x")

            subject
            expect(assigns(:settings)[:min_size]).to eq([30, 25])
          end

          context "and aspect ratio set on the settings" do
            let(:settings) do
              { fixed_ratio: "2" }
            end

            it "does not infer the height from the image file preserving the aspect ratio" do
              expect(croppable_resource).to receive(:render_size).at_least(:once).and_return("x25")

              subject
              expect(assigns(:settings)[:min_size]).to eq([50, 25])
            end
          end
        end

        context "when width or height is not fixed and an aspect ratio is given" do
          context "and aspect ratio set on the settings" do
            let(:settings) do
              { fixed_ratio: "0.5" }
            end

            it "width is given, it infers the height from width and ratio" do
              expect(croppable_resource).to receive(:render_size).at_least(:once).and_return("30x")

              subject
              expect(assigns(:settings)[:min_size]).to eq([30, 60])
            end
          end

          it "infers the height from the image file preserving the aspect ratio" do
            expect(croppable_resource).to receive(:render_size).at_least(:once).and_return("x25")

            subject
            expect(assigns(:settings)[:min_size]).to eq([30, 25])
          end
        end
      end

      context "no crop sizes present in croppable_resource" do
        it "assigns default mask boxes" do
          subject
          expect(assigns(:settings)[:default_box]).to eq(default_mask)
        end
      end

      context "crop sizes present in croppable_resource" do
        let(:mask) { [0, 0, 120, 160] }

        before do
          allow(croppable_resource).to receive(:crop_from).and_return("0x0")
          allow(croppable_resource).to receive(:crop_size).and_return("120x160")
        end

        it "assigns cropping boxes" do
          subject
          expect(assigns(:settings)[:default_box]).to eq(default_mask)
        end
      end

      context "with fixed_ratio set to false" do
        let(:settings) do
          { fixed_ratio: false }
        end

        it "sets ratio to false" do
          subject
          expect(assigns(:settings)[:ratio]).to eq(false)
        end
      end

      context "with fixed_ratio set to a non float string" do
        let(:settings) do
          { fixed_ratio: "123,45" }
        end

        it "raises error" do
          expect { subject }.to raise_error(ArgumentError)
        end
      end

      context "with no fixed_ratio set" do
        let(:settings) do
          { size: "80x60" }
        end

        it "sets a fixed ratio from sizes" do
          subject
          expect(assigns(:settings)[:ratio]).to eq(80.0 / 60.0)
        end
      end
    end
  end
end
