# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Admin::EssenceAudiosController do
  routes { Alchemy::Engine.routes }

  before do
    authorize_user(:as_author)
  end

  let(:essence_audio) { mock_model("Alchemy::EssenceAudio", attachment: nil, content: content) }
  let(:content) { mock_model("Alchemy::Content") }
  let(:attachment) { mock_model("Alchemy::Attachment") }

  describe "#edit" do
    before do
      expect(Alchemy::EssenceAudio).to receive(:find).with(essence_audio.id.to_s) { essence_audio }
    end

    it "assigns @essence_audio with the Alchemy::EssenceAudio found by id" do
      get :edit, params: { id: essence_audio.id }
      expect(assigns(:essence_audio)).to eq(essence_audio)
    end
  end

  describe "#update" do
    let(:essence_audio) { create(:alchemy_essence_audio) }

    let(:params) do
      {
        id: essence_audio.id,
        essence_audio: {
          autoplay: false,
          controls: true,
          loop: false,
          muted: true,
        },
      }
    end

    before do
      expect(Alchemy::EssenceAudio).to receive(:find) { essence_audio }
    end

    it "should update the attributes of essence_audio" do
      put :update, params: params, xhr: true
      expect(essence_audio.autoplay).to eq false
      expect(essence_audio.controls).to eq true
      expect(essence_audio.loop).to eq false
      expect(essence_audio.muted).to eq true
    end
  end
end
