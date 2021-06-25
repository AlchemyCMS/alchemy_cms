# frozen_string_literal: true

require "rails_helper"

module Alchemy
  describe Admin::EssencePicturesController do
    routes { Alchemy::Engine.routes }

    before { authorize_user(:as_admin) }

    let(:essence) { EssencePicture.new(content: content, picture: picture) }
    let(:content) { Content.new }
    let(:picture) { Picture.new }

    describe "#edit" do
      before do
        expect(EssencePicture).to receive(:find).and_return(essence)
        expect(Content).to receive(:find).and_return(content)
      end

      it "should assign @essence_picture and @content instance variables" do
        post :edit, params: { id: 1, content_id: 1 }
        expect(assigns(:essence_picture)).to be_a(EssencePicture)
        expect(assigns(:content)).to be_a(Content)
      end
    end

    it_behaves_like "having crop action", model_class: Alchemy::EssencePicture do
      let(:croppable_resource) { essence }
    end

    describe "#update" do
      before do
        expect(EssencePicture).to receive(:find).and_return(essence)
        expect(Content).to receive(:find).and_return(content)
      end

      let(:attributes) do
        {
          render_size: "1x1",
          alt_tag: "Alt Tag",
          caption: "Caption",
          css_class: "CSS Class",
          title: "Title",
        }
      end

      it "updates the essence attributes" do
        expect(essence).to receive(:update).and_return(true)
        put :update, params: { id: 1, essence_picture: attributes }, xhr: true
      end

      it "saves the cropping mask" do
        expect(essence).to receive(:update).and_return(true)
        put :update, params: {
                       id: 1,
                       essence_picture: {
                         render_size: "1x1",
                         crop_from: "0x0",
                         crop_size: "100x100",
                       },
                     }, xhr: true
      end
    end
  end
end
