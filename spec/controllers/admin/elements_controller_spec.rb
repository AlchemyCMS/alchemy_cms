require 'spec_helper'

module Alchemy
  describe Admin::ElementsController do

    before(:each) do
      activate_authlogic
      Alchemy::UserSession.create FactoryGirl.create(:admin_user)
    end

    let(:page) { FactoryGirl.create(:page, :urlname => 'lulu') }
    let(:element) { FactoryGirl.create(:element, :page_id => page.id) }
    let(:element_in_clipboard) { FactoryGirl.create(:element, :page_id => page.id) }
    let(:clipboard) { session[:clipboard] = Clipboard.new }

    describe '#create' do

      before { element }

      it "should insert the element at bottom of list" do
        post :create, {:element => {:name => 'news', :page_id => page.id}, :format => :js}
        page.elements.count.should == 2
        page.elements.last.name.should == 'news'
      end

      context "on a page with a setting for insert_elements_at of top" do

        before do
          PageLayout.stub(:get).and_return({
            'name' => 'news',
            'elements' => ['news'],
            'insert_elements_at' => 'top'
          })
        end

        it "should insert the element at top of list" do
          post :create, {:element => {:name => 'news', :page_id => page.id}, :format => :js}
          page.elements.count.should == 2
          page.elements.first.name.should == 'news'
        end
      end
    end

    describe '#find_or_create_cell' do

      before do
        Cell.stub!(:definition_for).and_return({'name' => 'header', 'elements' => ['header']})
        controller.instance_variable_set(:@page, page)
      end

      context "with element name and cell name in the params" do

        before do
          controller.stub(:params).and_return({
            :element => {:name => 'header#header'}
          })
        end

        context "with cell not existing" do
          it "should create the cell" do
            expect {
              controller.send(:find_or_create_cell)
            }.to change(page.cells, :count).from(0).to(1)
          end
        end

        context "with the cell already present" do

          before { FactoryGirl.create(:cell, :page => page, :name => 'header') }

          it "should load the cell" do
            expect {
              controller.send(:find_or_create_cell)
            }.to_not change(page.cells, :count)
          end

        end

      end

      context "with only the element name in the params" do

        before do
          controller.stub(:params).and_return({
            :element => {:name => 'header'}
          })
        end

        it "should return nil" do
          controller.send(:find_or_create_cell).should be_nil
        end

      end

    end

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
        post :order, {:element_ids => ["#{@element.id}"], :format => :js}
        @element.reload
        @element.position.should_not == nil
      end

      it "should assign the (new) page_id to the element" do
        post :order, {:element_ids => ["#{@element.id}"], :page_id => 1, :cell_id => nil, :format => :js}
        @element.reload
        @element.page_id.should == 1
      end

      it "should assign the (new) cell_id to the element" do
        post :order, {:element_ids => ["#{@element.id}"], :page_id => 1, :cell_id => 5, :format => :js}
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

      context "if page has cells" do

        context "" do

          before do
            @page = FactoryGirl.create(:public_page, :do_not_autogenerate => false)
            @cell = FactoryGirl.create(:cell, :name => 'header', :page => @page)
            PageLayout.stub(:get).and_return({
              'name' => 'standard',
              'elements' => ['article'],
              'cells' => ['header']
            })
            Cell.stub!(:definition_for).and_return({'name' => 'header', 'elements' => ['article']})
          end

          context "and cell name in element name" do

            it "should put the element in the correct cell" do
              post :create, {:element => {:name => "article#header", :page_id => @page.id}, :format => :js}
              @cell.elements.first.should be_an_instance_of(Element)
            end

          end

          context "and no cell name in element name" do

            it "should put the element in the main cell" do
              post :create, {:element => {:name => "article", :page_id => @page.id}, :format => :js}
              @page.elements.not_in_cell.first.should be_an_instance_of(Element)
            end

          end

        end

        context "with paste_from_clipboard in parameters" do

          context "" do
            before do
              @page = FactoryGirl.create(:public_page, :do_not_autogenerate => false)
              @cell = FactoryGirl.create(:cell, :name => 'header', :page => @page)
              PageLayout.stub(:get).and_return({
                'name' => 'standard',
                'elements' => ['article'],
                'cells' => ['header']
              })
              Cell.stub!(:definition_for).and_return({'name' => 'header', 'elements' => ['article']})
              clipboard[:elements] = [{:id => element_in_clipboard.id}]
            end

            context "and cell name in element name" do
              it "should create the element in the correct cell" do
                post :create, {:element => {:page_id => @page.id}, :paste_from_clipboard => "#{element_in_clipboard.id}##{@cell.name}", :format => :js}
                @cell.elements.first.should be_an_instance_of(Element)
              end
            end

            context "and no cell name in element name" do
              it "should create the element in the nil cell" do
                post :create, {:element => {:page_id => @page.id}, :paste_from_clipboard => "#{element_in_clipboard.id}", :format => :js}
                @page.elements.first.cell.should == nil
              end
            end

            context "" do

              before { @cell.elements.create(:page_id => @page.id, :name => "article", :create_contents_after_create => false) }

              it "should set the correct position for the element" do
                post :create, {:element => {:page_id => @page.id}, :paste_from_clipboard => "#{element_in_clipboard.id}##{@cell.name}", :format => :js}
                @cell.elements.last.position.should == @cell.elements.count
              end

            end
          end

          context "on a page with a setting for insert_elements_at of top" do
            let(:page)                 { FactoryGirl.create(:public_page, :name => 'News') }
            let(:element_in_clipboard) { FactoryGirl.create(:element, :page => page, :name => 'news') }
            let(:cell)                 { page.cells.first }
            let(:element)              { FactoryGirl.create(:element, :name => 'news', :page => page, :cell => cell) }

            before do
              PageLayout.stub(:get).and_return({
                'name' => 'news',
                'elements' => ['news'],
                'insert_elements_at' => 'top',
                'cells' => ['news']
              })
              Cell.stub!(:definition_for).and_return({'name' => 'news', 'elements' => ['news']})
              clipboard[:elements] = [{:id => element_in_clipboard.id}]
              cell.elements << element
            end

            it "should insert the element at top of list" do
              post :create, {:element => {:name => 'news', :page_id => page.id}, :paste_from_clipboard => "#{element_in_clipboard.id}##{cell.name}", :format => :js}
              cell.elements.count.should == 2
              cell.elements.first.name.should == 'news'
              cell.elements.first.should_not == element
            end
          end

        end

      end

      context "with paste_from_clipboard in parameters" do

        render_views

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
