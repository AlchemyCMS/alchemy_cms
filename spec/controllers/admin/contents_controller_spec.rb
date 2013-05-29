require 'spec_helper'

describe Alchemy::Admin::ContentsController do

  before(:each) do
    sign_in(admin_user)
  end

  describe '#create' do

    let(:element) { FactoryGirl.create(:element, :name => 'headline') }

    it "should create a content via ajax post" do
      length_before = element.contents.length
      post :create, {:content => {:element_id => element.id, :name => 'headline'}, :format => :js}
      element.contents.reload
      element.contents.length.should == length_before + 1
    end

  end

  describe '#update' do

    it "should update a content via ajax" do
      @element = FactoryGirl.create(:element, :create_contents_after_create => true)
      post :update, {:id => @element.contents.find_by_name('intro').id, :content => {:body => 'Peters Petshop'}, :format => :js}
      @element.ingredient('intro').should == "Peters Petshop"
    end

  end

  describe "#order" do

    context "with content_ids in params" do

      before(:each) do
        @element = FactoryGirl.create(:element, :create_contents_after_create => true)
      end

      it "should reorder the contents" do
        content_ids = @element.contents.essence_texts.collect(&:id)
        post :order, {:content_ids => content_ids.reverse, :format => :js}
        response.status.should == 200
        @element.contents.essence_texts.collect(&:id).should == content_ids.reverse
      end

    end

  end

end
