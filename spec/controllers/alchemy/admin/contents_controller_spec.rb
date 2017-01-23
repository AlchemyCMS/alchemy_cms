require 'spec_helper'

module Alchemy
  describe Admin::ContentsController do
    before do
      authorize_user(:as_admin)
    end

    context 'with element_id parameter' do
      describe '#create' do
        let(:element) { create(:alchemy_element, name: 'headline') }

        it "creates a content from name" do
          expect {
            alchemy_xhr :post, :create, {content: {element_id: element.id, name: 'headline'}}
          }.to change { Alchemy::Content.count }.by(1)
        end

        it "creates a content from essence_type" do
          expect {
            alchemy_xhr :post, :create, {
              content: {
                element_id: element.id, essence_type: 'EssencePicture'
              }
            }
          }.to change { Alchemy::Content.count }.by(1)
        end
      end

      context 'inside a picture gallery' do
        let(:element) { create(:alchemy_element) }

        let(:attributes) do
          {
            content: {
              element_id: element.id,
              essence_type: 'Alchemy::EssencePicture'
            },
            options: {
              grouped: 'true'
            }
          }
        end

        it "adds it into the gallery editor" do
          alchemy_xhr :post, :create, attributes
          expect(assigns(:content_dom_id)).to eq("#add_picture_#{element.id}")
        end

        context 'with picture_id given' do
          it "assigns the picture to the essence" do
            alchemy_xhr :post, :create, attributes.merge(picture_id: '1')
            expect(Alchemy::Content.last.essence.picture_id).to eq(1)
          end
        end
      end
    end

    describe '#update' do
      let(:content) { create(:alchemy_content) }

      before do
        expect(Content).to receive(:find).and_return(content)
      end

      it "should update a content via ajax" do
        expect {
          alchemy_xhr :post, :update, {id: content.id, content: {ingredient: 'Peters Petshop'}}
        }.to change { content.ingredient }.to 'Peters Petshop'
      end
    end

    describe "#order" do
      context "with content_ids in params" do
        let(:element) do
          create(:alchemy_element, name: 'all_you_can_eat', create_contents_after_create: true)
        end

        let(:content_ids) { element.contents.pluck(:id).shuffle }

        it "should reorder the contents" do
          alchemy_xhr :post, :order, {content_ids: content_ids}

          expect(response.status).to eq(200)
          expect(element.contents(true).pluck(:id)).to eq(content_ids)
        end
      end
    end
  end
end
