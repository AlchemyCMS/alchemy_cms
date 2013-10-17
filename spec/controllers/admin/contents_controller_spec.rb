require 'spec_helper'

describe Alchemy::Admin::ContentsController do
  before { sign_in(admin_user) }

  let(:element) { FactoryGirl.create(:element, create_contents_after_create: true) }

  describe '#create' do
    let(:element) { FactoryGirl.create(:element, name: 'headline') }

    it "creates a content from name" do
      expect {
        xhr :post, :create, {content: {element_id: element.id, name: 'headline'}}
      }.to change{element.contents.count}.by(1)
    end

    it "creates a content from essence_type" do
      expect {
        xhr :post, :create, {content: {element_id: element.id, essence_type: 'EssencePicture'}}
      }.to change{element.contents.count}.by(1)
    end
  end

  describe '#update' do
    it "should update a content via ajax" do
      xhr :post, :update, {id: element.contents.find_by_name('intro').id, content: {ingredient: 'Peters Petshop'}}
      element.ingredient('intro').should == "Peters Petshop"
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
