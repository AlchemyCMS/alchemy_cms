require 'spec_helper'



module Alchemy
  module Admin

    describe TrashController do

      render_views

      before(:each) do
        activate_authlogic
        UserSession.create FactoryGirl.create(:admin_user)
      end

      let(:page) do
        FactoryGirl.create(:page, :parent_id => Page.rootpage.id)
      end

      let(:element) do
        FactoryGirl.create(:element, :public => false)
      end

      it "should hold trashed elements" do
        # Because of a before_create filter it can not be created with a nil position and needs to be trashed here
        element.trash
        get :index, :page_id => page.id
        response.body.should have_selector("#trash_items #element_#{element.id}.element_editor")
      end

      it "should not hold elements that are not trashed" do
        element = FactoryGirl.create(:element, :page_id => 5, :public => false)
        get :index, :page_id => page.id
        response.body.should_not have_selector("#trash_items #element_#{element.id}.element_editor")
      end

      context "#clear" do

        it "should destroy all containing elements" do
          # Because of a before_create filter it can not be created with a nil position and needs to be trashed here
          element.trash
          post :clear, {:page_id => 1}
          Element.trashed.should be_empty
        end

      end

    end

  end
end
