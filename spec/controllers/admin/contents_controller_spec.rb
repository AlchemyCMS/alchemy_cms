require 'spec_helper'

module Alchemy
  describe Admin::ContentsController do
    let(:element) { build_stubbed(:element) }
    let(:content) { build_stubbed(:content, element: element) }

    before do
      authorize_user(:as_admin)
    end

    context 'with element_id parameter' do
      before do
        expect(Element).to receive(:find).and_return(element)
      end

      describe '#create' do
        let(:element) { build_stubbed(:element, name: 'headline') }

        it "creates a content from name" do
          expect(Content).to receive(:create_from_scratch).and_return(content)
          alchemy_xhr :post, :create, {content: {element_id: element.id, name: 'headline'}}
        end

        it "creates a content from essence_type" do
          expect(Content).to receive(:create_from_scratch).and_return(content)
          alchemy_xhr :post, :create, {content: {element_id: element.id, essence_type: 'EssencePicture'}}
        end
      end

      context 'inside a picture gallery' do
        let(:attributes) do
          {content: {element_id: element.id, essence_type: 'Alchemy::EssencePicture'}, options: {grouped: 'true'}}
        end

        it "adds it into the gallery editor" do
          alchemy_xhr :post, :create, attributes
          expect(assigns(:content_dom_id)).to eq("#add_picture_#{element.id}")
        end

        context 'with picture_id given' do
          it "assigns the picture" do
            expect_any_instance_of(Content).to receive(:update_essence).with(picture_id: '1')
            alchemy_xhr :post, :create, attributes.merge(picture_id: '1')
          end
        end
      end
    end

    describe '#update' do
      before do
        expect(Content).to receive(:find).and_return(content)
      end

      it "should update a content via ajax" do
        expect(content.essence).to receive(:update).with('ingredient' => 'Peters Petshop')
        alchemy_xhr :post, :update, {id: content.id, content: {ingredient: 'Peters Petshop'}}
      end
    end

    describe "#order" do
      context "with content_ids in params" do
        it "should reorder the contents" do
          content_ids = element.contents.essence_texts.pluck(:id)
          alchemy_xhr :post, :order, {content_ids: content_ids.reverse}
          expect(response.status).to eq(200)
          expect(element.contents.essence_texts.pluck(:id)).to eq(content_ids.reverse)
        end
      end
    end
  end
end
