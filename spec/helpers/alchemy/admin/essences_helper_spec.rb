# frozen_string_literal: true

require "rails_helper"

describe Alchemy::Admin::EssencesHelper do
  include Alchemy::Admin::ElementsHelper

  let(:element) do
    create(:alchemy_element, :with_contents, name: "article")
  end

  describe "#essence_picture_thumbnail" do
    let(:essence) do
      create(:alchemy_essence_picture)
    end

    let(:content) do
      create(:alchemy_content, essence: essence)
    end

    it "should return an image tag with thumbnail url from essence" do
      expect(essence).to receive(:thumbnail_url).and_call_original
      expect(helper.essence_picture_thumbnail(content)).to \
        have_selector("img[src].img_paddingtop")
    end

    context "when given content has no ingredient" do
      before { allow(content).to receive(:ingredient).and_return(nil) }

      it "should return nil" do
        expect(helper.essence_picture_thumbnail(content)).to eq(nil)
      end
    end
  end

  describe "#edit_picture_dialog_size" do
    let(:content) { build_stubbed(:alchemy_content) }

    subject { edit_picture_dialog_size(content) }

    context "with content having setting caption_as_textarea being true and sizes set" do
      before do
        allow(content).to receive(:settings) do
          {
            caption_as_textarea: true,
            sizes: ["100x100", "200x200"],
          }
        end

        it { is_expected.to eq("380x320") }
      end
    end

    context "with content having setting caption_as_textarea being true and no sizes set" do
      before do
        allow(content).to receive(:settings) do
          {
            caption_as_textarea: true,
          }
        end

        it { is_expected.to eq("380x300") }
      end
    end

    context "with content having setting caption_as_textarea being false and sizes set" do
      before do
        allow(content).to receive(:settings) do
          {
            caption_as_textarea: false,
            sizes: ["100x100", "200x200"],
          }
        end

        it { is_expected.to eq("380x290") }
      end
    end

    context "with content having setting caption_as_textarea being false and no sizes set" do
      before do
        allow(content).to receive(:settings) do
          {
            caption_as_textarea: false,
          }
        end

        it { is_expected.to eq("380x255") }
      end
    end
  end
end
