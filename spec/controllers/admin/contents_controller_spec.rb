require 'spec_helper'

describe Alchemy::Admin::ContentsController do

	before(:each) do
		activate_authlogic
		Alchemy::UserSession.create FactoryGirl.create(:admin_user)
	end

	it "should update a content via ajax" do
		@element = FactoryGirl.create(:element)
		post :update, {:id => @element.contents.find_by_name('intro').id, :content => {:body => 'Peters Petshop'}, :format => :js}
		@element.ingredient('intro').should == "Peters Petshop"
	end

	describe "#order" do

		context "with content_ids in params" do

			before(:each) do
				@element = FactoryGirl.create(:element)
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
