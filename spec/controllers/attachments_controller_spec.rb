require 'spec_helper'

module Alchemy
  describe AttachmentsController do
    let(:attachment) { build_stubbed(:attachment) }

    it "should raise ActiveRecord::RecordNotFound for requesting not existing attachments" do
      expect { alchemy_get :download, id: 0 }.to raise_error(ActiveRecord::RecordNotFound)
    end

    context 'with public attachment' do
      before do
        allow(Attachment).to receive(:find).and_return(attachment)
      end

      it "sends download as attachment." do
        alchemy_get :download, :id => attachment.id
        expect(response.status).to eq(200)
        expect(response.headers['Content-Disposition']).to match(/attachment/)
      end

      it "sends download inline." do
        alchemy_get :show, :id => attachment.id
        expect(response.status).to eq(200)
        expect(response.headers['Content-Disposition']).to match(/inline/)
      end
    end

    context 'with restricted attachment' do
      before do
        allow(attachment).to receive(:restricted?).and_return(true)
        allow(Attachment).to receive(:find).and_return(attachment)
      end

      context 'as anonymous user' do
        it "should not be possible to download attachments from restricted pages" do
          alchemy_get :download, :id => attachment.id
          expect(response.status).to eq(302)
          expect(response).to redirect_to(Alchemy.login_path)
        end

        it "should not be possible to see attachments from restricted pages" do
          alchemy_get :show, :id => attachment.id
          expect(response.status).to eq(302)
          expect(response).to redirect_to(Alchemy.login_path)
        end
      end

      context "as member user" do
        before { authorize_user(build(:alchemy_dummy_user)) }

        it "should be possible to download attachments from restricted pages" do
          alchemy_get :download, :id => attachment.id
          expect(response.status).to eq(200)
        end

        it "should be possible to see attachments from restricted pages" do
          alchemy_get :show, :id => attachment.id
          expect(response.status).to eq(200)
        end
      end
    end
  end
end
