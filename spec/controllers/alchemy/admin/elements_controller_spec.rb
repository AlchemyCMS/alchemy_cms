require 'spec_helper'

module Alchemy
  describe Admin::ElementsController do
    let(:alchemy_page) { create(:alchemy_page) }

    let(:element) do
      create(:alchemy_element, page_version_id: alchemy_page.current_version_id)
    end

    let(:element_in_clipboard) do
      create(:alchemy_element, page_version_id: alchemy_page.current_version_id)
    end

    let(:clipboard) { session[:alchemy_clipboard] = {} }

    before { authorize_user(:as_author) }

    describe '#index' do
      let(:alchemy_page) { build_stubbed(:alchemy_page) }

      before do
        expect(Page).to receive(:find_by).and_return alchemy_page
      end

      context 'with cells' do
        let(:cell) { create(:alchemy_cell, page: alchemy_page) }

        before do
          alchemy_page.cells << cell
        end

        it "groups elements by cell" do
          expect(alchemy_page).to receive(:elements_grouped_by_cells)
          alchemy_get :index, {page_id: alchemy_page.id}
          expect(assigns(:cells)).to eq([cell])
        end
      end

      context 'without cells' do
        it "assigns page elements" do
          expect(alchemy_page).to receive(:current_elements).and_return(double(not_trashed: []))
          alchemy_get :index, {page_id: alchemy_page.id}
        end
      end
    end

    describe '#list' do
      context 'without page_id, but with page_urlname' do
        it "loads page from urlname" do
          alchemy_xhr :get, :list, {page_urlname: alchemy_page.urlname}
          expect(assigns(:elements)).to eq(alchemy_page.current_elements.published)
        end

        describe 'view' do
          render_views

          it "returns a select tag with elements" do
            alchemy_xhr :get, :list, {page_id: alchemy_page.id}
            expect(response.body).to match(/select(.*)elements_from_page_selector(.*)option/)
          end
        end
      end

      context 'with page_id' do
        it "loads elements from page id" do
          alchemy_xhr :get, :list, {page_id: alchemy_page.id}
          expect(assigns(:elements)).to eq(alchemy_page.current_elements.published)
        end
      end
    end

    describe '#order' do
      let(:element_1) do
        create(:alchemy_element, page_version: alchemy_page.current_version)
      end

      let(:element_2) do
        create(:alchemy_element, page_version: alchemy_page.current_version)
      end

      let(:element_3) do
        create(:alchemy_element, page_version: alchemy_page.current_version)
      end

      let(:element_ids) do
        [element_1.id, element_3.id, element_2.id]
      end

      it "sets new position for given element ids" do
        alchemy_xhr :post, :order, page_id: alchemy_page.id, element_ids: element_ids
        expect(Element.all.pluck(:id)).to eq(element_ids)
      end

      context 'with missing [:element_ids] param' do
        it 'does not raise any error and silently rejects to order' do
          expect {
            alchemy_xhr :post, :order, page_id: alchemy_page.id
          }.to_not raise_error
        end
      end

      context "when nested inside parent element" do
        let(:parent) { create(:alchemy_element) }

        it 'touches the cache key of parent element' do
          expect(Element).to receive(:find_by) { parent }
          expect(parent).to receive(:touch) { true }
          alchemy_xhr :post, :order,
            page_id: alchemy_page.id,
            element_ids: element_ids,
            parent_element_id: parent.id
        end

        it 'assigns parent element id to each element' do
          alchemy_xhr :post, :order,
            page_id: alchemy_page.id,
            element_ids: element_ids,
            parent_element_id: parent.id
          [element_1, element_2, element_3].each do |element|
            expect(element.reload.parent_element_id).to eq parent.id
          end
        end
      end

      context "untrashing" do
        let(:trashed_element) do
          create(:alchemy_element, page_version_id: alchemy_page.current_version_id)
        end

        let(:other_page) { create(:alchemy_page) }

        before do
          # Because of a before_create filter it can not be created with a nil position
          # and needs to be trashed here
          trashed_element.trash!
        end

        it "sets a list of trashed element ids" do
          alchemy_xhr :post, :order, page_id: alchemy_page.id, element_ids: [trashed_element.id]
          expect(assigns(:trashed_element_ids).to_a).to eq [trashed_element.id]
        end

        it "sets a new position to the element" do
          alchemy_xhr :post, :order, page_id: alchemy_page.id, element_ids: [trashed_element.id]
          trashed_element.reload
          expect(trashed_element.position).to_not be_nil
        end

        it "should assign the (new) page_version_id to the element" do
          alchemy_xhr :post, :order, element_ids: [trashed_element.id], page_id: other_page.id, cell_id: nil
          trashed_element.reload
          expect(trashed_element.page_version_id).to be other_page.current_version_id
        end

        context "with cell_id present" do
          let(:cell) { create(:alchemy_cell) }

          it "should assign the (new) cell_id to the element" do
            alchemy_xhr :post, :order,
              element_ids: [trashed_element.id],
              page_id: alchemy_page.id,
              cell_id: cell.id

            trashed_element.reload
            expect(trashed_element.cell_id).to be cell.id
          end
        end
      end
    end

    describe '#new' do
      let(:alchemy_page) do
        build_stubbed(:alchemy_page)
      end

      before do
        allow(Page).to receive(:find_by).and_return(alchemy_page)
      end

      it "assign variable for all available element definitions" do
        expect(alchemy_page).to receive(:available_element_definitions)
        alchemy_get :new, {page_id: alchemy_page.id}
      end

      context "with elements in clipboard" do
        let(:element) { build_stubbed(:alchemy_element) }

        let(:clipboard_items) do
          [{'id' => element.id.to_s, 'action' => 'copy'}]
        end

        before do
          clipboard['elements'] = clipboard_items
        end

        it "should load all elements from clipboard" do
          expect(Element).to receive(:all_from_clipboard_for_page).and_return(clipboard_items)
          alchemy_get :new, {page_id: alchemy_page.id}
          expect(assigns(:clipboard_items)).to eq(clipboard_items)
        end
      end
    end

    describe '#create' do
      describe 'insertion position' do
        before { element }

        it "inserts the element at bottom of list" do
          alchemy_xhr :post, :create, page_id: alchemy_page.id, element: {name: 'news'}
          expect(alchemy_page.current_elements.count).to eq(2)
          expect(alchemy_page.current_elements.last.name).to eq('news')
        end

        context "on a page with a setting for insert_elements_at of top" do
          before do
            expect(PageLayout).to receive(:get).at_least(:once).and_return({
              'name' => 'news',
              'elements' => ['news'],
              'insert_elements_at' => 'top'
            })
          end

          it "should insert the element at top of list" do
            alchemy_xhr :post, :create, page_id: alchemy_page.id, element: {name: 'news'}
            expect(alchemy_page.current_elements.count).to eq(2)
            expect(alchemy_page.current_elements.first.name).to eq('news')
          end
        end
      end

      context "if page has cells" do
        let(:page) { create(:alchemy_page, :public, do_not_autogenerate: false) }
        let(:cell) { page.cells.first }

        context "not pasting from clipboard" do
          context "and cell name in element name" do
            before do
              expect(PageLayout).to receive(:get).at_least(:once).and_return({
                'name' => 'standard',
                'elements' => ['article'],
                'cells' => ['header']
              })
              expect(Cell).to receive(:definition_for).and_return({
                'name' => 'header',
                'elements' => ['article']
              })
            end

            it "should put the element in the correct cell" do
              alchemy_xhr :post, :create, page_id: page.id, element: {name: "article#header"}
              expect(cell.elements.first).to be_an_instance_of(Element)
            end
          end

          context "and no cell name in element name" do
            it "should put the element in the main cell" do
              alchemy_xhr :post, :create, page_id: page.id, element: {name: "article"}
              expect(page.current_elements.not_in_cell.first).to be_an_instance_of(Element)
            end
          end
        end

        context "pasting from clipboard" do
          context "with default element insert position" do
            before do
              expect(PageLayout).to receive(:get).at_least(:once).and_return({
                'name' => 'standard',
                'elements' => ['article'],
                'cells' => ['header']
              })
              clipboard['elements'] = [{'id' => element_in_clipboard.id.to_s}]
            end

            context "and cell name in element name" do
              before do
                expect(Cell).to receive(:definition_for).at_least(:once).and_return({
                  'name' => 'header',
                  'elements' => ['article']
                })
              end

              it "should create the element in the correct cell" do
                alchemy_xhr :post, :create, page_id: page.id, element: {}, paste_from_clipboard: "#{element_in_clipboard.id}##{cell.name}"
                expect(cell.elements.first).to be_an_instance_of(Element)
              end

              context "with elements already in cell" do
                before do
                  cell.elements.create(
                    page_version_id: page.current_version_id,
                    name: "article",
                    create_contents_after_create: false
                  )
                end

                it "should set the correct position for the element" do
                  alchemy_xhr :post, :create, page_id: page.id, element: {}, paste_from_clipboard: "#{element_in_clipboard.id}##{cell.name}"
                  expect(cell.elements.last.position).to eq(cell.elements.count)
                end
              end
            end

            context "and no cell name in element name" do
              it "should create the element in the nil cell" do
                alchemy_xhr :post, :create, page_id: page.id, element: {}, paste_from_clipboard: element_in_clipboard.id.to_s
                expect(page.current_elements.first.cell).to eq(nil)
              end
            end
          end

          context "on a page with a setting for insert_elements_at of top" do
            let!(:alchemy_page) do
              create(:alchemy_page, :public, name: 'News')
            end

            let!(:element_in_clipboard) do
              create :alchemy_element,
                page_version: alchemy_page.current_version,
                name: 'news'
            end

            let!(:cell) do
              create(:alchemy_cell, name: 'news', page: alchemy_page)
            end

            let!(:element) do
              create :alchemy_element,
                page_version: alchemy_page.current_version,
                name: 'news',
                cell: cell
            end

            before do
              expect(PageLayout).to receive(:get).at_least(:once).and_return({
                'name' => 'news',
                'elements' => ['news'],
                'insert_elements_at' => 'top',
                'cells' => ['news']
              })

              expect(Cell).to receive(:definition_for).and_return({
                'name' => 'news',
                'elements' => ['news']
              })

              clipboard['elements'] = [{'id' => element_in_clipboard.id.to_s}]
              cell.elements << element
            end

            it "should insert the element at top of list" do
              alchemy_xhr :post, :create, page_id: alchemy_page.id, element: {name: 'news'}, paste_from_clipboard: "#{element_in_clipboard.id}##{cell.name}"
              expect(cell.elements.count).to eq(2)
              expect(cell.elements.first.name).to eq('news')
              expect(cell.elements.first).not_to eq(element)
            end
          end
        end
      end

      context "pasting from clipboard" do
        render_views

        before do
          clipboard['elements'] = [{'id' => element_in_clipboard.id.to_s, 'action' => 'cut'}]
        end

        it "should create an element from clipboard" do
          alchemy_xhr :post, :create, page_id: alchemy_page.id, paste_from_clipboard: element_in_clipboard.id, element: {}
          expect(response.status).to eq(200)
          expect(response.body).to match(/Successfully added new element/)
        end

        context "and with cut as action parameter" do
          it "should also remove the element id from clipboard" do
            alchemy_xhr :post, :create, page_id: alchemy_page.id, paste_from_clipboard: element_in_clipboard.id, element: {}
            expect(session[:alchemy_clipboard]['elements'].detect { |item| item['id'] == element_in_clipboard.id.to_s }).to be_nil
          end
        end
      end

      context 'if element could not be saved' do
        subject { alchemy_post :create, page_id: alchemy_page.id, element: {} }

        before do
          expect_any_instance_of(Element).to receive(:save).and_return false
        end

        it "renders the new template" do
          expect(subject).to render_template(:new)
        end
      end
    end

    describe '#find_or_create_cell' do
      before do
        controller.instance_variable_set(:@page, alchemy_page)
      end

      context "with element name and cell name in the params" do
        before do
          expect(Cell).to receive(:definition_for).and_return({
            'name' => 'header',
            'elements' => ['header']
          })
          allow(controller).to receive(:params).and_return({element: {name: 'header#header'}})
        end

        context "with cell not existing" do
          it "should create the cell" do
            expect {
              controller.send(:find_or_create_cell)
            }.to change(alchemy_page.cells, :count).from(0).to(1)
          end
        end

        context "with the cell already present" do
          before do
            create(:alchemy_cell, page: alchemy_page, name: 'header')
          end

          it "should load the cell" do
            expect {
              controller.send(:find_or_create_cell)
            }.to_not change(alchemy_page.cells, :count)
          end
        end
      end

      context "with only the element name in the params" do
        before do
          allow(controller).to receive(:params).and_return({element: {name: 'header'}})
        end

        it "should return nil" do
          expect(controller.send(:find_or_create_cell)).to be_nil
        end
      end

      context 'with cell definition not found' do
        before do
          allow(controller).to receive(:params).and_return({element: {name: 'header#header'}})
          expect(Cell).to receive(:definition_for).and_return nil
        end

        it "raises error" do
          expect { controller.send(:find_or_create_cell) }.to raise_error(CellDefinitionError)
        end
      end
    end

    describe '#update' do
      let(:page)    { build_stubbed(:alchemy_page) }
      let(:element) { build_stubbed(:alchemy_element, page: page) }
      let(:contents_parameters) { ActionController::Parameters.new(1 => {ingredient: 'Title'}) }
      let(:element_parameters) { ActionController::Parameters.new(tag_list: 'Tag 1', public: false) }

      before do
        expect(Element).to receive(:find).and_return element
        expect(controller).to receive(:contents_params).and_return(contents_parameters)
      end

      it "updates all contents in element" do
        expect(element).to receive(:update_contents).with(contents_parameters)
        alchemy_xhr :put, :update, {id: element.id}
      end

      it "updates the element" do
        expect(controller).to receive(:element_params).and_return(element_parameters)
        expect(element).to receive(:update_contents).and_return(true)
        expect(element).to receive(:update_attributes!).with(element_parameters).and_return(true)
        alchemy_xhr :put, :update, {id: element.id}
      end

      context "failed validations" do
        it "displays validation failed notice" do
          expect(element).to receive(:update_contents).and_return(false)
          alchemy_xhr :put, :update, {id: element.id}
          expect(assigns(:element_validated)).to be_falsey
        end
      end
    end

    describe 'params security' do
      context "contents params" do
        let(:parameters) { ActionController::Parameters.new(contents: {1 => {ingredient: 'Title'}}) }

        specify ":contents is required" do
          expect(controller.params).to receive(:fetch).and_return(parameters)
          controller.send :contents_params
        end

        specify "everything is permitted" do
          expect(controller).to receive(:params).and_return(parameters)
          expect(parameters).to receive(:fetch).and_return(parameters)
          expect(parameters).to receive(:permit!)
          controller.send :contents_params
        end
      end

      context "element params" do
        let(:parameters) { ActionController::Parameters.new(element: {public: true}) }

        before do
          expect(controller).to receive(:params).and_return(parameters)
          expect(parameters).to receive(:fetch).with(:element, {}).and_return(parameters)
        end

        context 'with taggable element' do
          before do
            controller.instance_variable_set(:'@element', mock_model(Element, taggable?: true))
          end

          specify ":tag_list is permitted" do
            expect(parameters).to receive(:permit).with(:tag_list)
            controller.send :element_params
          end
        end

        context 'with not taggable element' do
          before do
            controller.instance_variable_set(:'@element', mock_model(Element, taggable?: false))
          end

          specify ":tag_list is not permitted" do
            expect(parameters).to_not receive(:permit)
            controller.send :element_params
          end
        end
      end
    end

    describe '#trash' do
      subject { alchemy_xhr :delete, :trash, {id: element.id} }

      let(:element) { build_stubbed(:alchemy_element) }

      before { expect(Element).to receive(:find).and_return element }

      it "trashes the element instead of deleting it" do
        expect(element).to receive(:trash!).and_return(true)
        subject
      end
    end

    describe '#fold' do
      subject { alchemy_xhr :post, :fold, {id: element.id} }

      let(:element) { build_stubbed(:alchemy_element) }

      before do
        expect(element).to receive(:save).and_return true
        expect(Element).to receive(:find).and_return element
      end

      context 'if element is folded' do
        before { expect(element).to receive(:folded).and_return true }

        it "sets folded to false." do
          expect(element).to receive(:folded=).with(false).and_return(false)
          subject
        end
      end

      context 'if element is not folded' do
        before { expect(element).to receive(:folded).and_return false }

        it "sets folded to true." do
          expect(element).to receive(:folded=).with(true).and_return(true)
          subject
        end
      end
    end
  end
end
