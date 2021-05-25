# frozen_string_literal: true

require "rails_helper"

module Alchemy
  describe Admin::EssenceFilesController do
    routes { Alchemy::Engine.routes }

    before do
      authorize_user(:as_admin)
    end

    let(:essence_file) { mock_model("EssenceFile", :attachment= => nil, content: content) }
    let(:content) { mock_model("Content") }
    let(:attachment) { mock_model("Attachment") }

    describe "#edit" do
      before do
        expect(EssenceFile).to receive(:find).with(essence_file.id.to_s) { essence_file }
      end

      it "assigns @essence_file with the EssenceFile found by id" do
        get :edit, params: { id: essence_file.id }
        expect(assigns(:essence_file)).to eq(essence_file)
      end

      it "should assign @content with essence_file's content" do
        get :edit, params: { id: essence_file.id }
        expect(assigns(:content)).to eq(content)
      end
    end

    describe "#update" do
      let(:essence_file) { create(:alchemy_essence_file) }

      let(:params) do
        {
          id: essence_file.id,
          essence_file: {
            title: "new title",
            css_class: "left",
            link_text: "Download this file",
          },
        }
      end

      before do
        expect(EssenceFile).to receive(:find) { essence_file }
      end

      it "should update the attributes of essence_file" do
        put :update, params: params, xhr: true
        expect(essence_file.title).to eq "new title"
        expect(essence_file.css_class).to eq "left"
        expect(essence_file.link_text).to eq "Download this file"
      end
    end
  end
end
