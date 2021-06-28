# frozen_string_literal: true

require "rails_helper"

RSpec.describe "alchemy/ingredients/_audio_editor" do
  let(:element) { build_stubbed(:alchemy_element, name: "all_you_can_eat_ingredients") }
  let(:element_editor) { Alchemy::ElementEditor.new(element) }
  let(:attachment) { build_stubbed(:alchemy_attachment) }

  let(:ingredient) do
    stub_model(
      Alchemy::Ingredients::Audio,
      element: element,
      attachment: attachment,
      role: "file",
    )
  end

  let(:audio_editor) { Alchemy::IngredientEditor.new(ingredient) }
  let(:settings) { {} }

  subject do
    render element_editor
    rendered
  end

  before do
    allow(element_editor).to receive(:ingredients) { [Alchemy::IngredientEditor.new(ingredient)] }
    view.class.send(:include, Alchemy::Admin::IngredientsHelper)
    allow(ingredient).to receive(:settings) { settings }
    allow(audio_editor).to receive(:attachment) { attachment }
  end

  it_behaves_like "an alchemy ingredient editor"

  context "with attachment present" do
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
      let(:settings) { { only: "mp3" } }

      it "renders a link to open the attachment library overlay with only mp3s" do
        within ".file_tools" do
          is_expected.to have_selector("a[href='/admin/attachments?form_field_id=element_ingredients_attributes_0_attachment_id&only=mp3']")
        end
      end
    end

    context "with settings `except`" do
      let(:settings) { { except: "mp3" } }

      it "renders a link to open the attachment library overlay without mp3s" do
        within ".file_tools" do
          is_expected.to have_selector("a[href='/admin/attachments?form_field_id=element_ingredients_attributes_0_attachment_id&except=mp3']")
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
