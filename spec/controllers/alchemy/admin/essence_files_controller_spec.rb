# frozen_string_literal: true

require "spec_helper"

module Alchemy
  describe Admin::EssenceFilesController do
    routes { Alchemy::Engine.routes }

    before do
      authorize_user(:as_admin)
    end

    let(:essence_file) { mock_model('EssenceFile', :attachment= => nil, content: content) }
    let(:content)      { mock_model('Content') }
    let(:attachment)   { mock_model('Attachment') }

    describe '#edit' do
      before do
        expect(EssenceFile).to receive(:find)
          .with(essence_file.id.to_s)
          .and_return(essence_file)
      end

      it "assigns @essence_file with the EssenceFile found by id" do
        get :edit, params: {id: essence_file.id}
        expect(assigns(:essence_file)).to eq(essence_file)
      end

      it "should assign @content with essence_file's content" do
        get :edit, params: {id: essence_file.id}
        expect(assigns(:content)).to eq(content)
      end
    end

    describe '#update' do
      let(:essence_file) { create(:alchemy_essence_file) }

      before do
        expect(EssenceFile).to receive(:find).and_return(essence_file)
      end

      it "should update the attributes of essence_file" do
        put :update, params: {
          id: essence_file.id,
          essence_file: {
            title: 'new title',
            css_class: 'left',
            link_text: 'Download this file'
          }
        }, xhr: true
        expect(essence_file.title).to eq 'new title'
        expect(essence_file.css_class).to eq 'left'
        expect(essence_file.link_text).to eq 'Download this file'
      end
    end

    describe '#assign' do
      let(:content) { create(:alchemy_content) }

      before do
        expect(Content).to receive(:find_by).and_return(content)
        expect(Attachment).to receive(:find_by).and_return(attachment)
        allow(content).to receive(:essence).and_return(essence_file)
      end

      it "should assign @attachment with the Attachment found by attachment_id" do
        put :assign, params: {content_id: content.id, attachment_id: attachment.id}, xhr: true
        expect(assigns(:attachment)).to eq(attachment)
      end

      it "should assign @content.essence.attachment with the attachment found by id" do
        expect(content.essence).to receive(:attachment=).with(attachment)
        put :assign, params: {content_id: content.id, attachment_id: attachment.id}, xhr: true
      end

      it "updates the @content.updated_at column" do
        content.update_column(:updated_at, 3.days.ago)
        expect {
          put :assign, params: {content_id: content.id, attachment_id: attachment.id}, xhr: true
        }.to change(content, :updated_at)
      end
    end
  end
end
