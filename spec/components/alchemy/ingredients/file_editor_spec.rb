# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Ingredients::FileEditor, type: :component do
  let(:element) { build_stubbed(:alchemy_element, name: "all_you_can_eat") }
  let(:attachment) { build_stubbed(:alchemy_attachment) }

  let(:ingredient) do
    stub_model(
      Alchemy::Ingredients::File,
      element: element,
      attachment: attachment,
      role: "file"
    )
  end

  let(:file_editor) { described_class.new(ingredient) }
  let(:settings) { {} }

  subject do
    render_inline file_editor
    page
  end

  before do
    vc_test_view_context.class.include Alchemy::Admin::BaseHelper
    allow(ingredient).to receive(:settings) { settings }
    allow(file_editor).to receive(:attachment) { attachment }
    allow(vc_test_view_context).to receive(:can?).and_return(true)
  end

  it_behaves_like "an alchemy ingredient editor"

  it "renders a alchemy-file-editor" do
    is_expected.to have_selector("alchemy-file-editor")
  end

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
      let(:settings) { {only: "pdf"} }

      it "renders a link to open the attachment library overlay with only pdfs" do
        is_expected.to have_selector("a[href='/admin/attachments?form_field_id=element_#{element.id}_ingredient_#{ingredient.id}_attachment_id&only%5B%5D=pdf']")
      end
    end

    context "with settings `except`" do
      let(:settings) { {except: "pdf"} }

      it "renders a link to open the attachment library overlay without pdfs" do
        is_expected.to have_selector("a[href='/admin/attachments?except%5B%5D=pdf&form_field_id=element_#{element.id}_ingredient_#{ingredient.id}_attachment_id']")
      end
    end
  end

  context "without attachment present" do
    let(:attachment) { nil }

    it "renders a hidden field for attachment_id" do
      is_expected.to have_selector("input[type='hidden'][name='#{file_editor.form_field_name(:attachment_id)}']")
    end
  end

  context "without edit permission" do
    before do
      allow(vc_test_view_context).to receive(:can?).and_return(false)
    end

    it "does not render the remove file link" do
      is_expected.not_to have_selector(".remove_file_link")
    end

    it "renders a disabled assign file link without tooltip" do
      is_expected.to have_selector(".file_tools a.disabled")
      is_expected.not_to have_selector(".file_tools a[href*='attachments']")
      is_expected.not_to have_selector(".file_tools a.file_icon[title]")
    end

    it "renders a disabled edit properties link without tooltip" do
      is_expected.not_to have_selector(".file_tools a[href*='edit']")
      is_expected.to have_selector(".file_tools a.disabled:not([title])", count: 2)
    end
  end
end
