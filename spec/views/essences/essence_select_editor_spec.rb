# frozen_string_literal: true

require "rails_helper"

RSpec.describe "alchemy/essences/_essence_select_editor" do
  let(:content) { Alchemy::Content.new(essence: essence) }
  let(:essence) { Alchemy::EssenceSelect.new }

  before do
    view.class.send(:include, Alchemy::Admin::BaseHelper)
    allow(view).to receive(:content_label).and_return(content.name)
  end

  subject do
    render "alchemy/essences/essence_select_editor", essence_select_editor: Alchemy::ContentEditor.new(content)
    rendered
  end

  context "if no select values are set" do
    it "renders a warning" do
      is_expected.to have_css(".warning")
    end
  end

  context "if select values are set" do
    before do
      expect(content).to receive(:settings).at_least(:once) do
        {
          select_values: %w(red blue yellow),
        }
      end
    end

    it "renders a select box" do
      is_expected.to have_css("select.alchemy_selectbox")
    end
  end
end
