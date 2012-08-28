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
        Alchemy::Element.stub_chain([:published, :find_all_by_page_id]).and_return([element])
        get :list, {:page_urlname => page.urlname, :format => :js}
        response.body.should match(/select(.*)elements_from_page_selector(.*)option/)
      end

    end

    describe "untrashing" do

      before(:each) do
        @element = FactoryGirl.create(:element, :public => false, :position => nil, :page_id => 58, :cell_id => 32)
        # Because of a before_create filter it can not be created with a nil position and needs to be trashed here
        @element.trash
      end

      it "should set a new position to the element" do
        post :order, {:element_ids => ["#{@element.id}"]}
        @element.reload
        @element.position.should_not == nil
      end

      it "should assign the (new) page_id to the element" do
        post :order, {:element_ids => ["#{@element.id}"], :page_id => 1, :cell_id => nil}
        @element.reload
        @element.page_id.should == 1
      end

      it "should assign the (new) cell_id to the element" do
        post :order, {:element_ids => ["#{@element.id}"], :page_id => 1, :cell_id => 5}
        @element.reload
        @element.cell_id.should == 5
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

      context "with cells" do

        before do
          @page = FactoryGirl.create(:public_page, :do_not_autogenerate => false)
          @cell = FactoryGirl.create(:cell, :name => 'header', :page => @page)
          Page.any_instance.stub(:can_have_cells?).and_return(true)
          Cell.stub!(:definition_for).and_return({'name' => 'header', 'elements' => ['article']})
        end

        context "and cell name in element name" do

          it "should put the element in the correct cell" do
            post :create, {:element => {:name => "article#header", :page_id => @page.id}}
            @cell.elements.first.should be_an_instance_of(Element)
          end

        end

        context "and no cell name in element name" do

          it "should put the element in the main cell" do
            post :create, {:element => {:name => "article", :page_id => @page.id}}
            @page.elements.not_in_cell.first.should be_an_instance_of(Element)
          end

        end

      end

      context "with paste_from_clipboard in parameters" do

        render_views

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
