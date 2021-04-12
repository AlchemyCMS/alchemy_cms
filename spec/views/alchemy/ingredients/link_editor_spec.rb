# frozen_string_literal: true

require "rails_helper"

describe "alchemy/essences/_essence_link_editor" do
  let(:essence) { Alchemy::EssenceLink.new(link: "http://alchemy-cms.com") }
  let(:content) { Alchemy::Content.new(essence: essence) }
  let(:settings) { {} }

  before do
    view.class.send :include, Alchemy::Admin::BaseHelper
    allow(view).to receive(:content_label).and_return("1e Zahl")
    render partial: "alchemy/essences/essence_link_editor", locals: {
      essence_link_editor: Alchemy::ContentEditor.new(content),
    }
  end

  it "renders a disabled text input field" do
    expect(rendered).to have_selector('input[type="text"][disabled]')
  end

  it "renders link buttons" do
    expect(rendered).to have_selector('input[type="hidden"][name="contents[][link]"]')
    expect(rendered).to have_selector('input[type="hidden"][name="contents[][link_title]"]')
    expect(rendered).to have_selector('input[type="hidden"][name="contents[][link_class_name]"]')
    expect(rendered).to have_selector('input[type="hidden"][name="contents[][link_target]"]')
  end
end
