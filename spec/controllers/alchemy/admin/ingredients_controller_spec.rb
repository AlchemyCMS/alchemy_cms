# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Admin::IngredientsController do
  routes { Alchemy::Engine.routes }

  let(:attachment) { build_stubbed(:alchemy_attachment) }
  let(:element) { build(:alchemy_element, name: "all_you_can_eat_ingredients") }

  let(:ingredient) do
    stub_model(
      Alchemy::Ingredients::File,
      type: "Alchemy::Ingredients::File",
      element: element,
      attachment: attachment,
      role: "file",
    )
  end

  before do
    allow(Alchemy::Ingredient).to receive(:find).with(ingredient.id.to_s) { ingredient }
  end

  context "without authorized user" do
    describe "get :edit" do
      it "redirects to login path" do
        get :edit, params: { id: ingredient.id }
        expect(response).to redirect_to(Alchemy.login_path)
      end
    end

    describe "patch :update" do
      it "redirects to login path" do
        patch :update, params: { id: ingredient.id }
        expect(response).to redirect_to(Alchemy.login_path)
      end
    end
  end

  context "with autorized user" do
    before do
      authorize_user(:as_admin)
    end

    describe "get :edit" do
      subject { get(:edit, params: { id: ingredient.id }) }

      it "assigns @ingredient with the Ingredient found by id" do
        subject
        expect(assigns(:ingredient)).to eq(ingredient)
      end

      it "renders edit template" do
        expect(subject).to render_template("alchemy/admin/ingredients/edit")
      end
    end

    describe "patch :update" do
      context "with permitted attributes" do
        let(:params) do
          {
            id: ingredient.id,
            ingredient: {
              title: "new title",
              css_class: "left",
              link_text: "Download this file",
            },
          }
        end

        it "updates the attributes of ingredient" do
          patch :update, params: params, xhr: true
          expect(ingredient.title).to eq "new title"
          expect(ingredient.css_class).to eq "left"
          expect(ingredient.link_text).to eq "Download this file"
        end
      end

      context "with unpermitted attributes" do
        let(:params) do
          {
            id: ingredient.id,
            ingredient: {
              foo: "Baz",
            },
          }
        end

        it "does not update the attributes of ingredient" do
          expect(ingredient).to receive(:update).with({})
          patch :update, params: params, xhr: true
        end
      end
    end

    it_behaves_like "having crop action", model_class: Alchemy::Ingredient do
      let(:croppable_resource) do
        Alchemy::Ingredient.build(
          type: "Alchemy::Ingredients::Picture",
          element: element,
          attachment: attachment,
          role: "picture",
        )
      end
    end
  end
end
