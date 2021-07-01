# frozen_string_literal: true

require "rails_helper"

module Alchemy
  describe Admin::ElementsController do
    routes { Alchemy::Engine.routes }

    let(:page_version) { create(:alchemy_page_version) }
    let(:element) { create(:alchemy_element, page_version: page_version) }
    let(:element_in_clipboard) { create(:alchemy_element, page_version: page_version) }
    let(:clipboard) { session[:alchemy_clipboard] = {} }

    before { authorize_user(:as_author) }

    describe "#index" do
      let!(:page_version) { create(:alchemy_page_version) }
      let!(:element) { create(:alchemy_element, page_version: page_version) }
      let!(:nested_element) { create(:alchemy_element, :nested, page_version: page_version) }
      let!(:hidden_element) { create(:alchemy_element, page_version: page_version, public: false) }

      context "with fixed elements" do
        let!(:fixed_element) do
          create(:alchemy_element, :fixed, page_version: page_version)
        end

        let!(:fixed_hidden_element) do
          create(:alchemy_element, :fixed, public: false, page_version: page_version)
        end

        it "assigns fixed elements" do
          get :index, params: { page_version_id: page_version.id }
          expect(assigns(:fixed_elements)).to eq([fixed_element, fixed_hidden_element])
        end
      end

      it "assigns elements" do
        get :index, params: { page_version_id: page_version.id }
        expect(assigns(:elements)).to eq([element, nested_element.parent_element, hidden_element])
      end
    end

    describe "#order" do
      let!(:element_1) { create(:alchemy_element) }
      let!(:element_2) { create(:alchemy_element, page_version: page_version) }
      let!(:element_3) { create(:alchemy_element, page_version: page_version) }
      let(:element_ids) { [element_1.id, element_3.id, element_2.id] }
      let(:page_version) { element_1.page_version }

      it "sets new position for given element ids" do
        post :order, params: { element_ids: element_ids }, xhr: true
        expect(Element.all.pluck(:id, :position)).to eq([
          [element_1.id, 1],
          [element_3.id, 2],
          [element_2.id, 3],
        ])
      end

      context "with missing [:element_ids] param" do
        it "does not raise any error and silently rejects to order" do
          expect { post :order, xhr: true }.to_not raise_error
        end
      end

      context "when nested inside parent element" do
        let(:parent) { create(:alchemy_element) }

        it "touches the cache key of parent element" do
          parent.update_column(:updated_at, 3.days.ago)
          expect {
            post :order, params: {
                           element_ids: element_ids,
                           parent_element_id: parent.id,
                         }, xhr: true
          }.to change { parent.reload.updated_at }
        end

        it "assigns parent element id to each element" do
          post :order, params: {
                         element_ids: element_ids,
                         parent_element_id: parent.id,
                       }, xhr: true
          [element_1, element_2, element_3].each do |element|
            expect(element.reload.parent_element_id).to eq parent.id
          end
        end
      end
    end

    describe "#new" do
      let(:page_version) { create(:alchemy_page_version) }

      it "assign variable for all available element definitions" do
        expect_any_instance_of(Alchemy::Page).to receive(:available_element_definitions)
        get :new, params: { page_version_id: page_version.id }
      end

      context "with elements in clipboard" do
        let(:element) { create(:alchemy_element, page_version: page_version) }
        let(:clipboard_items) { [{ "id" => element.id.to_s, "action" => "copy" }] }

        before { clipboard["elements"] = clipboard_items }

        it "should load all elements from clipboard" do
          expect(Element).to receive(:all_from_clipboard_for_page).and_return(clipboard_items)
          get :new, params: { page_version_id: page_version.id }
          expect(assigns(:clipboard_items)).to eq(clipboard_items)
        end
      end
    end

    describe "#create" do
      describe "insertion position" do
        before { element }

        it "should insert the element at bottom of list" do
          post :create, params: { element: { name: "news", page_version_id: page_version.id } }, xhr: true
          expect(page_version.elements.count).to eq(2)
          expect(page_version.elements.order(:position).last.name).to eq("news")
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
            post :create, params: { element: { name: "news", page_version_id: page_version.id } }, xhr: true
            expect(page_version.elements.count).to eq(2)
            expect(page_version.elements.order(:position).first.name).to eq("news")
          end
        end
      end

      context "with parent_element_id given" do
        let(:parent_element) do
          create(:alchemy_element, :with_nestable_elements, page_version: page_version)
        end

        it "creates the element in the parent element" do
          post :create, params: { element: { name: "slide", page_version_id: page_version.id, parent_element_id: parent_element.id } }, xhr: true
          expect(Alchemy::Element.last.parent_element_id).to eq(parent_element.id)
        end
      end

      context "pasting from clipboard" do
        render_views

        before do
          clipboard["elements"] = [{ "id" => element_in_clipboard.id.to_s, "action" => "cut" }]
        end

        it "should create an element from clipboard" do
          post :create, params: { paste_from_clipboard: element_in_clipboard.id, element: { page_version_id: page_version.id } }, xhr: true
          expect(response.status).to eq(200)
          expect(response.body).to match(/Successfully added new element/)
        end

        context "and with cut as action parameter" do
          it "should also remove the element id from clipboard" do
            post :create, params: { paste_from_clipboard: element_in_clipboard.id, element: { page_version_id: page_version.id } }, xhr: true
            expect(session[:alchemy_clipboard]["elements"].detect { |item| item["id"] == element_in_clipboard.id.to_s }).to be_nil
          end
        end

        context "with parent_element_id given" do
          let(:element_in_clipboard) { create(:alchemy_element, :nested, page_version: page_version) }
          let(:parent_element) { create(:alchemy_element, :with_nestable_elements) }

          it "moves the element to new parent" do
            post :create, params: { paste_from_clipboard: element_in_clipboard.id, element: { page_version_id: page_version.id, parent_element_id: parent_element.id } }, xhr: true
            expect(Alchemy::Element.last.parent_element_id).to eq(parent_element.id)
          end
        end
      end

      context "if element could not be saved" do
        subject { post :create, params: { element: { page_version_id: page_version.id } } }

        before do
          expect_any_instance_of(Element).to receive(:save).and_return false
        end

        it "renders the new template" do
          expect(subject).to render_template(:new)
        end
      end
    end

    describe "#update" do
      before do
        expect(Element).to receive(:find).at_least(:once).and_return(element)
      end

      context "with element having contents" do
        subject do
          put :update, params: { id: element.id, element: element_params, contents: contents_params }, xhr: true
        end

        let(:element) { create(:alchemy_element, :with_contents) }
        let(:content) { element.contents.first }
        let(:element_params) { { tag_list: "Tag 1", public: false } }
        let(:contents_params) { { content.id => { ingredient: "Title" } } }

        it "updates all contents in element" do
          expect { subject }.to change { content.reload.ingredient }.to("Title")
        end

        it "updates the element" do
          expect { subject }.to change { element.tag_list }.to(["Tag 1"])
        end

        context "failed validations" do
          it "displays validation failed notice" do
            expect(element).to receive(:update_contents).and_return(false)
            subject
            expect(assigns(:element_validated)).to be_falsey
          end
        end
      end

      context "with element having ingredients" do
        subject do
          put :update, params: { id: element.id, element: element_params }, xhr: true
        end

        let(:element) { create(:alchemy_element, :with_ingredients) }
        let(:ingredient) { element.ingredients.first }
        let(:ingredients_attributes) { { 0 => { id: ingredient.id, value: "Title" } } }
        let(:element_params) { { tag_list: "Tag 1", public: false, ingredients_attributes: ingredients_attributes } }

        it "updates all ingredients in element" do
          expect { subject }.to change { ingredient.value }.to("Title")
        end

        it "updates the element" do
          expect { subject }.to change { element.tag_list }.to(["Tag 1"])
        end

        context "failed validations" do
          it "displays validation failed notice" do
            expect(element).to receive(:update).and_return(false)
            subject
            expect(assigns(:element_validated)).to be_falsey
          end
        end
      end
    end

    describe "#destroy" do
      subject { delete :destroy, params: { id: element.id }, xhr: true }

      let!(:element) { create(:alchemy_element) }

      it "deletes the element" do
        expect { subject }.to change(Alchemy::Element, :count).to(0)
      end
    end

    describe "#fold" do
      subject { post :fold, params: { id: element.id }, xhr: true }

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
