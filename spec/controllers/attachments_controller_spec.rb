require 'spec_helper'

module Alchemy
  describe AttachmentsController, :type => :controller do
    let(:attachment) { build_stubbed(:attachment) }

    it "should raise ActiveRecord::RecordNotFound for requesting not existing attachments" do
      expect { get :download, id: 0 }.to raise_error(ActiveRecord::RecordNotFound)
    end

    context 'with restricted attachment' do
      before do
        allow(attachment).to receive(:restricted?).and_return(true)
        allow(Attachment).to receive(:find).and_return(attachment)
      end

      context 'as anonymous user' do
        it "should not be possible to download attachments from restricted pages" do
          get :download, :id => attachment.id
          expect(response.status).to eq(302)
          expect(response).to redirect_to(Alchemy.login_path)
        end

        it "should not be possible to see attachments from restricted pages" do
          get :show, :id => attachment.id
          expect(response.status).to eq(302)
          expect(response).to redirect_to(Alchemy.login_path)
        end
      end

      context "as member user" do
        before { sign_in(member_user) }

        it "should be possible to download attachments from restricted pages" do
          get :download, :id => attachment.id
          expect(response.status).to eq(200)
        end

        it "should be possible to see attachments from restricted pages" do
          get :show, :id => attachment.id
          expect(response.status).to eq(200)
        end
      end
    end
  end
end
