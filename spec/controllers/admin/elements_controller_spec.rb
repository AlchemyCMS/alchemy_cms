require 'spec_helper'

module Alchemy
  describe Admin::ElementsController do

    before(:each) do
      activate_authlogic
      Alchemy::UserSession.create FactoryGirl.create(:admin_user)
    end

    let(:page) { mock_model('Page', {:id => 1, :urlname => 'lulu'}) }
    let(:element) { mock_model('Element', {:id => 1, :page_id => page.id, :public => true, :display_name_with_preview_text => 'lalaa', :dom_id => 1}) }

    describe '#list' do

      render_views

      it "should return a select tag with elements" do
        Alchemy::Page.should_receive(:find_by_urlname_and_language_id).and_return(page)
        Alchemy::Element.should_receive(:find_all_by_page_id_and_public).and_return([element])
        get :list, {:page_urlname => page.urlname, :format => :js}
        response.body.should match(/select(.*)elements_from_page_selector(.*)option/)
      end

    end

    describe '#new' do

      context "elements in clipboard" do

        let(:clipboard) { session[:clipboard] = Clipboard.new }

        before(:each) do
          clipboard[:elements] = [{:id => element.id, :action => 'copy'}]
        end

        it "should load all elements from clipboard" do
          get :new, {:page_id => page.id, :format => :js}
          assigns(:clipboard_items).should be_kind_of(Array)
        end

      end

    end

    describe '#create' do

      render_views

      context "with paste_from_clipboard in parameters" do

        let(:clipboard) { session[:clipboard] = Clipboard.new }
        let(:element_in_clipboard) { @element ||= FactoryGirl.create(:element, :page_id => page.id) }

        before(:each) do
          clipboard[:elements] = [{:id => element_in_clipboard.id, :action => 'cut'}]
        end

        it "should create an element from clipboard" do
          post :create, {:paste_from_clipboard => element_in_clipboard.id, :element => {:page_id => page.id}, :format => :js}
          response.status.should == 200
          response.body.should match(/Succesfully added new element/)
        end

        context "and with cut as action parameter" do

          it "should also remove the element id from clipboard" do
            post :create, {:paste_from_clipboard => element_in_clipboard.id, :element => {:page_id => page.id}, :format => :js}
            session[:clipboard].contains?(:elements, element_in_clipboard.id).should_not be_true
          end

        end

      end

    end

  end
end
