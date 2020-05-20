# frozen_string_literal: true

require "rails_helper"

module Alchemy
  describe Admin::ElementsController do
    routes { Alchemy::Engine.routes }

    let(:alchemy_page)         { create(:alchemy_page) }
    let(:element)              { create(:alchemy_element, page: alchemy_page) }
    let(:element_in_clipboard) { create(:alchemy_element, page: alchemy_page) }
    let(:clipboard)            { session[:alchemy_clipboard] = {} }

    before { authorize_user(:as_author) }

    describe "#index" do
      let!(:alchemy_page)    { create(:alchemy_page) }
      let!(:element)         { create(:alchemy_element, page: alchemy_page) }
      let!(:trashed_element) { create(:alchemy_element, page: alchemy_page).tap(&:trash!) }
      let!(:nested_element)  { create(:alchemy_element, :nested, page: alchemy_page) }
      let!(:hidden_element)  { create(:alchemy_element, page: alchemy_page, public: false) }

      context "with fixed elements" do
        let!(:fixed_element) do
          create(:alchemy_element, :fixed,
            page: alchemy_page)
        end

        let!(:fixed_hidden_element) do
          create(:alchemy_element, :fixed,
            public: false,
            page: alchemy_page)
        end

        let!(:fixed_trashed_element) do
          create(:alchemy_element, :fixed,
            public: false,
            page: alchemy_page).tap(&:trash!)
        end

        it "assigns fixed elements" do
          get :index, params: {page_id: alchemy_page.id}
          expect(assigns(:fixed_elements)).to eq([fixed_element, fixed_hidden_element])
        end
      end

      it "assigns page elements" do
        get :index, params: {page_id: alchemy_page.id}
        expect(assigns(:elements)).to eq([element, hidden_element])
      end
    end

    describe "#order" do
      let(:element_1)   { create(:alchemy_element) }
      let(:element_2)   { create(:alchemy_element, page: page) }
      let(:element_3)   { create(:alchemy_element, page: page) }
      let(:element_ids) { [element_1.id, element_3.id, element_2.id] }
      let(:page)        { element_1.page }

      it "sets new position for given element ids" do
        post :order, params: {page_id: page.id, element_ids: element_ids}, xhr: true
        expect(Element.all.pluck(:id)).to eq(element_ids)
      end

      context "with missing [:element_ids] param" do
        it "does not raise any error and silently rejects to order" do
          expect {
            post :order, params: {page_id: page.id}, xhr: true
          }.to_not raise_error
        end
      end

      context "when nested inside parent element" do
        let(:parent) { create(:alchemy_element) }

        it "touches the cache key of parent element" do
          expect(Element).to receive(:find_by) { parent }
          expect(parent).to receive(:touch) { true }
          post :order, params: {
            page_id: page.id,
            element_ids: element_ids,
            parent_element_id: parent.id,
          }, xhr: true
        end

        it "assigns parent element id to each element" do
          post :order, params: {
            page_id: page.id,
            element_ids: element_ids,
            parent_element_id: parent.id,
          }, xhr: true
          [element_1, element_2, element_3].each do |element|
            expect(element.reload.parent_element_id).to eq parent.id
          end
        end
      end

      context "untrashing" do
        let!(:trashed_element) { create(:alchemy_element).tap(&:trash!) }

        it "sets a list of trashed element ids" do
          post :order, params: {page_id: page.id, element_ids: [trashed_element.id]}, xhr: true
          expect(assigns(:trashed_element_ids).to_a).to eq [trashed_element.id]
        end

        it "sets a new position to the element" do
          post :order, params: {page_id: page.id, element_ids: [trashed_element.id]}, xhr: true
          trashed_element.reload
          expect(trashed_element.position).to_not be_nil
        end

        context "with new page_id present" do
          let(:page) { create(:alchemy_page) }

          it "should assign the (new) page_id to the element" do
            post :order, params: {element_ids: [trashed_element.id], page_id: page.id}, xhr: true
            trashed_element.reload
            expect(trashed_element.page_id).to be page.id
          end
        end
      end
    end

    describe "#new" do
      let(:alchemy_page) { build_stubbed(:alchemy_page) }

      before do
        expect(Page).to receive(:find).and_return(alchemy_page)
      end

      it "assign variable for all available element definitions" do
        expect(alchemy_page).to receive(:available_element_definitions)
        get :new, params: {page_id: alchemy_page.id}
      end

      context "with elements in clipboard" do
        let(:element) { build_stubbed(:alchemy_element) }
        let(:clipboard_items) { [{"id" => element.id.to_s, "action" => "copy"}] }

        before { clipboard["elements"] = clipboard_items }

        it "should load all elements from clipboard" do
          expect(Element).to receive(:all_from_clipboard_for_page).and_return(clipboard_items)
          get :new, params: {page_id: alchemy_page.id}
          expect(assigns(:clipboard_items)).to eq(clipboard_items)
        end
      end
    end

    describe "#create" do
      describe "insertion position" do
        before { element }

        it "should insert the element at bottom of list" do
          post :create, params: {element: {name: "news", page_id: alchemy_page.id}}, xhr: true
          expect(alchemy_page.elements.count).to eq(2)
          expect(alchemy_page.elements.last.name).to eq("news")
        end

        context "on a page with a setting for insert_elements_at of top" do
          before do
            expect(PageLayout).to receive(:get).at_least(:once).and_return({
              "name" => "news",
              "elements" => ["news"],
              "insert_elements_at" => "top",
            })
          end

          it "should insert the element at top of list" do
            post :create, params: {element: {name: "news", page_id: alchemy_page.id}}, xhr: true
            expect(alchemy_page.elements.count).to eq(2)
            expect(alchemy_page.elements.first.name).to eq("news")
          end
        end
      end

      context "with parent_element_id given" do
        let(:parent_element) { create(:alchemy_element, :with_nestable_elements, page: alchemy_page) }

        it "creates the element in the parent element" do
          post :create, params: {element: {name: "slide", page_id: alchemy_page.id, parent_element_id: parent_element.id}}, xhr: true
          expect(Alchemy::Element.last.parent_element_id).to eq(parent_element.id)
        end
      end

      context "pasting from clipboard" do
        render_views

        before do
          clipboard["elements"] = [{"id" => element_in_clipboard.id.to_s, "action" => "cut"}]
        end

        it "should create an element from clipboard" do
          post :create, params: {paste_from_clipboard: element_in_clipboard.id, element: {page_id: alchemy_page.id}}, xhr: true
          expect(response.status).to eq(200)
          expect(response.body).to match(/Successfully added new element/)
        end

        context "and with cut as action parameter" do
          it "should also remove the element id from clipboard" do
            post :create, params: {paste_from_clipboard: element_in_clipboard.id, element: {page_id: alchemy_page.id}}, xhr: true
            expect(session[:alchemy_clipboard]["elements"].detect { |item| item["id"] == element_in_clipboard.id.to_s }).to be_nil
          end
        end

        context "with parent_element_id given" do
          let(:element_in_clipboard) { create(:alchemy_element, :nested, page: alchemy_page) }
          let(:parent_element) { create(:alchemy_element, :with_nestable_elements, page: alchemy_page) }

          it "moves the element to new parent" do
            post :create, params: {paste_from_clipboard: element_in_clipboard.id, element: {page_id: alchemy_page.id, parent_element_id: parent_element.id}}, xhr: true
            expect(Alchemy::Element.last.parent_element_id).to eq(parent_element.id)
          end
        end
      end

      context "if element could not be saved" do
        subject { post :create, params: {element: {page_id: alchemy_page.id}} }

        before do
          expect_any_instance_of(Element).to receive(:save).and_return false
        end

        it "renders the new template" do
          expect(subject).to render_template(:new)
        end
      end
    end

    describe "#update" do
      let(:page)    { build_stubbed(:alchemy_page) }
      let(:element) { build_stubbed(:alchemy_element, page: page) }
      let(:contents_parameters) { ActionController::Parameters.new(1 => {ingredient: "Title"}) }
      let(:element_parameters) { ActionController::Parameters.new(tag_list: "Tag 1", public: false) }

      before do
        expect(Element).to receive(:find).and_return element
        expect(controller).to receive(:contents_params).and_return(contents_parameters)
      end

      it "updates all contents in element" do
        expect(element).to receive(:update_contents).with(contents_parameters)
        put :update, params: {id: element.id}, xhr: true
      end

      it "updates the element" do
        expect(controller).to receive(:element_params).and_return(element_parameters)
        expect(element).to receive(:update_contents).and_return(true)
        expect(element).to receive(:update).with(element_parameters).and_return(true)
        put :update, params: {id: element.id}, xhr: true
      end

      context "failed validations" do
        it "displays validation failed notice" do
          expect(element).to receive(:update_contents).and_return(false)
          put :update, params: {id: element.id}, xhr: true
          expect(assigns(:element_validated)).to be_falsey
        end
      end
    end

    describe "params security" do
      context "contents params" do
        let(:parameters) { ActionController::Parameters.new(contents: {1 => {ingredient: "Title"}}) }

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

        context "with taggable element" do
          before do
            controller.instance_variable_set(:'@element', mock_model(Element, taggable?: true))
          end

          specify ":tag_list is permitted" do
            expect(parameters).to receive(:permit).with(:tag_list)
            controller.send :element_params
          end
        end

        context "with not taggable element" do
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

    describe "#trash" do
      subject { delete :trash, params: {id: element.id}, xhr: true }

      let(:element) { build_stubbed(:alchemy_element) }

      before { expect(Element).to receive(:find).and_return element }

      it "trashes the element instead of deleting it" do
        expect(element).to receive(:trash!).and_return(true)
        subject
      end
    end

    describe "#fold" do
      subject { post :fold, params: {id: element.id}, xhr: true }

      let(:element) { build_stubbed(:alchemy_element) }

      before do
        expect(element).to receive(:save).and_return true
        expect(Element).to receive(:find).and_return element
      end

      context "if element is folded" do
        before { expect(element).to receive(:folded).and_return true }

        it "sets folded to false." do
          expect(element).to receive(:folded=).with(false).and_return(false)
          subject
        end
      end

      context "if element is not folded" do
        before { expect(element).to receive(:folded).and_return false }

        it "sets folded to true." do
          expect(element).to receive(:folded=).with(true).and_return(true)
          subject
        end
      end
    end
  end
end
