require 'spec_helper'

describe 'alchemy/essences/_essence_boolean_editor' do
  let(:essence) { Alchemy::EssenceBoolean.new(ingredient: false) }
  let(:content) { Alchemy::Content.new(essence: essence, name: 'Boolean') }

  before do
    view.stub(:render_content_name).and_return(content.name)
    view.stub(:delete_content_link).and_return('')
  end

  it "renders a checkbox" do
    render partial: "alchemy/essences/essence_boolean_editor", locals: {content: content}
    expect(rendered).to have_selector('input[type="checkbox"]')
  end

  context 'with default value given in view local options' do
    it "checks the checkbox" do
      render partial: "alchemy/essences/essence_boolean_editor", locals: {content: content, options: {default_value: true}}
      expect(rendered).to have_selector('input[type="checkbox"][checked="checked"]')
    end
  end

  context 'with default value given in content settings' do
    before { content.stub(settings: {default_value: true}) }

    it "checks the checkbox" do
      render partial: "alchemy/essences/essence_boolean_editor", locals: {content: content}
      expect(rendered).to have_selector('input[type="checkbox"][checked="checked"]')
    end
  end
end
