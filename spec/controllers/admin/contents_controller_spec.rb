require 'spec_helper'

module Alchemy
  describe Admin::ContentsController do
    let(:element) { build_stubbed(:element) }
    let(:content) { build_stubbed(:content, element: element) }

    before do
      sign_in(admin_user)
      Element.stub(find: element)
    end

    describe '#create' do
      let(:element) { build_stubbed(:element, name: 'headline') }

      it "creates a content from name" do
        Content.should_receive(:create_from_scratch).and_return(content)
        xhr :post, :create, {content: {element_id: element.id, name: 'headline'}}
      end

      it "creates a content from essence_type" do
        Content.should_receive(:create_from_scratch).and_return(content)
        xhr :post, :create, {content: {element_id: element.id, essence_type: 'EssencePicture'}}
      end
    end

    describe '#update' do
      before do
        Content.stub(find: content)
      end

      it "should update a content via ajax" do
        xhr :post, :update, {id: content.id, content: {ingredient: 'Peters Petshop'}}
        content.essence.body.should == "Peters Petshop"
      end
    end

    describe "#order" do
      context "with content_ids in params" do
        it "should reorder the contents" do
          content_ids = element.contents.essence_texts.collect(&:id)
          xhr :post, :order, {content_ids: content_ids.reverse}
          response.status.should == 200
          element.contents.essence_texts.collect(&:id).should == content_ids.reverse
        end
      end
    end
  end
end
