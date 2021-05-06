# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Admin::EssenceVideosController do
  routes { Alchemy::Engine.routes }

  before do
    authorize_user(:as_author)
  end

  let(:essence_video) { mock_model("Alchemy::EssenceVideo", attachment: nil, content: content) }
  let(:content) { mock_model("Alchemy::Content") }
  let(:attachment) { mock_model("Alchemy::Attachment") }

  describe "#edit" do
    before do
      expect(Alchemy::EssenceVideo).to receive(:find).with(essence_video.id.to_s) { essence_video }
    end

    it "assigns @essence_video with the Alchemy::EssenceVideo found by id" do
      get :edit, params: { id: essence_video.id }
      expect(assigns(:essence_video)).to eq(essence_video)
    end
  end

  describe "#update" do
    let(:essence_video) { create(:alchemy_essence_video) }

    let(:params) do
      {
        id: essence_video.id,
        essence_video: {
          width: "200",
          height: "150",
          autoplay: false,
          controls: true,
          loop: false,
          muted: true,
          preload: "auto",
        },
      }
    end

    before do
      expect(Alchemy::EssenceVideo).to receive(:find) { essence_video }
    end

    it "should update the attributes of essence_video" do
      put :update, params: params, xhr: true
      expect(essence_video.width).to eq "200"
      expect(essence_video.height).to eq "150"
      expect(essence_video.autoplay).to eq false
      expect(essence_video.controls).to eq true
      expect(essence_video.loop).to eq false
      expect(essence_video.muted).to eq true
      expect(essence_video.preload).to eq "auto"
    end
  end
end
