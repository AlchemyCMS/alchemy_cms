require 'spec_helper'

module Alchemy
  module Admin

    describe TrashController do

      render_views

      let(:page) do
        FactoryGirl.create(:page, :parent_id => Page.rootpage.id)
      end

      let(:element) do
        FactoryGirl.create(:element, :public => false, :page => page)
      end

      before do
        activate_authlogic
        UserSession.create FactoryGirl.create(:admin_user)
        element.trash
      end

      it "should hold trashed elements" do
        get :index, :page_id => page.id
        response.body.should have_selector("#element_#{element.id}.element_editor")
      end

      it "should not hold elements that are not trashed" do
        element = FactoryGirl.create(:element, :page => page, :public => false)
        get :index, :page_id => page.id
        response.body.should_not have_selector("#element_#{element.id}.element_editor")
      end

      context "with unique elements inside the trash" do

        before do
          Element.stub!(:all_definitions_for).and_return([
            {'name' => element.name, 'unique' => true}
          ])
        end

        context "and no unique elements on the page" do

          it "unique elements should be draggable" do
            get :index, :page_id => page.id
            response.body.should have_selector("#element_#{element.id}.element_editor.draggable")
          end

        end

        context "and with an unique element on the page" do

          it "unique elements should not be draggable" do
            FactoryGirl.create(:element, :page => page, :public => false)
            get :index, :page_id => page.id
            response.body.should have_selector("#element_#{element.id}.element_editor.not-draggable")
          end

        end

      end

      context "#clear" do

        it "should destroy all containing elements" do
          post :clear, {:page_id => page.id, :format => :js}
          Element.trashed.should be_empty
        end

      end

    end

  end
end
