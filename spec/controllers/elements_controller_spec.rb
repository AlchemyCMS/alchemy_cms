require 'spec_helper'

module Alchemy
  describe ElementsController do
    let(:public_page)         { FactoryGirl.create(:public_page) }
    let(:element)             { FactoryGirl.create(:element, :page => public_page, :name => 'download') }
    let(:restricted_page)     { FactoryGirl.create(:public_page, :restricted => true) }
    let(:restricted_element)  { FactoryGirl.create(:element, :page => restricted_page, :name => 'download') }

    describe '#show' do

      it "should render available elements" do
        get :show, :id => element.id
        response.status.should == 200
      end

      it "should raise ActiveRecord::RecordNotFound error for trashed elements" do
        element.trash!
        expect { get(:show, :id => element.id) }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it "should raise ActiveRecord::RecordNotFound error for unpublished elements" do
        element.update_attributes(:public => false)
        expect { get(:show, :id => element.id) }.to raise_error(ActiveRecord::RecordNotFound)
      end

      context "for guest user" do
        it "should raise ActiveRecord::RecordNotFound error for elements of restricted pages" do
          expect { get(:show, :id => restricted_element.id) }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context "for member user" do
        before { sign_in(member_user) }

        it "should render elements of restricted pages" do
          get :show, :id => restricted_element.id
          response.status.should == 200
        end
      end

    end

  end
end
