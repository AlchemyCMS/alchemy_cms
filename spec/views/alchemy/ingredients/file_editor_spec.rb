# frozen_string_literal: true

require "rails_helper"

describe "alchemy/ingredients/_file_editor" do
  let(:element) { build(:alchemy_element) }

  let(:ingredient) do
    stub_model(
      Alchemy::Ingredients::File,
      element: element,
      attachment: attachment,
      role: "file",
    )
  end

  let(:file_editor) { Alchemy::IngredientEditor.new(ingredient) }
  let(:settings) { {} }

  subject do
    render partial: "alchemy/ingredients/file_editor", locals: {
      file_editor: file_editor,
      file_editor_counter: 0,
    }
    rendered
  end

  before do
    # view.class.send(:include, Alchemy::Admin::BaseHelper)
    view.class.send(:include, Alchemy::Admin::IngredientsHelper)
    allow(ingredient).to receive(:settings) { settings }
    allow(file_editor).to receive(:attachment) { attachment }
  end

  context "with attachment present" do
    let(:attachment) { build_stubbed(:alchemy_attachment) }

    it "renders a hidden field with attachment id" do
      is_expected.to have_selector("input[type='hidden'][value='#{attachment.id}']")
    end

    it "renders a link to open the attachment library overlay" do
      within ".file_tools" do
        is_expected.to have_selector("a[href='/admin/attachments?form_field_id=element_ingredients_attributes_0_attachment_id']")
      end
    end

    it "renders a link to edit the ingredient" do
      within ".file_tools" do
        is_expected.to have_selector("a[href='/admin/ingredients/#{ingredient.id}/edit']")
      end
    end

    context "with settings `only`" do
      let(:settings) { { only: "pdf" } }

      it "renders a link to open the attachment library overlay with only pdfs" do
        within ".file_tools" do
          is_expected.to have_selector("a[href='/admin/attachments?form_field_id=element_ingredients_attributes_0_attachment_id&only=pdf']")
        end
      end
    end

    context "with settings `except`" do
      let(:settings) { { except: "pdf" } }

      it "renders a link to open the attachment library overlay without pdfs" do
        within ".file_tools" do
          is_expected.to have_selector("a[href='/admin/attachments?form_field_id=element_ingredients_attributes_0_attachment_id&except=pdf']")
        end
      end
    end
  end

  context "without attachment present" do
    let(:attachment) { nil }

    it "renders a hidden field for attachment_id" do
      is_expected.to have_selector("input[type='hidden'][name='element[ingredients_attributes][0][attachment_id]']")
    end
  end
end
