# frozen_string_literal: true

require "rails_helper"

describe "alchemy/essences/_essence_boolean_editor" do
  let(:element) { create(:alchemy_element, name: "all_you_can_eat") }
  let(:content) { Alchemy::Content.create(name: "essence_boolean", type: "EssenceBoolean", element: element) }

  let(:content_definition) do
    {
      name: "essence_boolean",
      type: "EssenceBoolean",
    }.with_indifferent_access
  end

  before do
    expect(element).to receive(:content_definition_for) { content_definition }
    allow_any_instance_of(Alchemy::Content).to receive(:definition) { content_definition }
    allow(view).to receive(:render_content_name).and_return(content.name)
    allow(view).to receive(:render_hint_for).and_return("")
  end

  subject do
    render partial: "alchemy/essences/essence_boolean_editor", locals: {
      essence_boolean_editor: Alchemy::ContentEditor.new(content),
    }
    rendered
  end

  it "renders a checkbox" do
    is_expected.to have_selector('input[type="checkbox"]')
  end

  context "with default value given in content settings" do
    let(:content_definition) do
      {
        name: "essence_boolean",
        type: "EssenceBoolean",
        default: true,
      }.with_indifferent_access
    end

    it "checks the checkbox" do
      is_expected.to have_selector('input[type="checkbox"][checked="checked"]')
    end
  end
end
