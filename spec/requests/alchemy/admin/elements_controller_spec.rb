# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Admin::ElementsController do
  before do
    authorize_user(:as_admin)
  end

  describe "#create" do
    let(:page_version) { create(:alchemy_page_version) }

    context "element with ingredients" do
      it "inits Tinymce for richtext ingredients" do
        post admin_elements_path(element: { page_version_id: page_version.id, name: "element_with_ingredients" }, format: :js)
        element = Alchemy::Element.last
        expect(response.body).to include("Alchemy.Tinymce.init([#{element.ingredient_by_role(:text).id}]);")
      end
    end
  end

  describe "#fold" do
    context "expanded element with ingredients" do
      let(:element) { create(:alchemy_element, :with_ingredients) }

      it "removes Tinymce for richtext ingredients" do
        post fold_admin_element_path(id: element.id, format: :js)
        expect(response.body).to include("Alchemy.Tinymce.remove([#{element.ingredient_by_role(:text).id}]);")
      end
    end

    context "folded element with ingredients" do
      let(:element) { create(:alchemy_element, :with_ingredients, folded: true) }

      it "inits Tinymce for richtext ingredients" do
        post fold_admin_element_path(id: element.id, format: :js)
        expect(response.body).to include("Alchemy.Tinymce.init([#{element.ingredient_by_role(:text).id}]);")
      end
    end
  end

  describe "#destroy" do
    context "element with ingredients" do
      let(:element) { create(:alchemy_element, :with_ingredients) }

      it "removes Tinymce for richtext ingredients" do
        delete admin_element_path(id: element.id, format: :js)
        expect(response.body).to include("Alchemy.Tinymce.remove([#{element.ingredient_by_role(:text).id}]);")
      end
    end
  end
end
