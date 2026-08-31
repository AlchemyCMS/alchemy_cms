# frozen_string_literal: true

require "rails_helper"

describe "alchemy/admin/partials/_main_navigation_entry.html.erb" do
  let(:alchemy_module) do
    {
      engine_name: "alchemy",
      name: "what_a_name",
      navigation: {
        controller: "alchemy/admin/pages",
        action: "index",
        name: "Pages",
        image: "alchemy/alchemy-logo.svg",
        data: {turbo: false},
        sub_navigation: []
      }
    }.with_indifferent_access
  end

  let(:navigation) { alchemy_module[:navigation] }

  before do
    allow(view).to receive(:can?).and_return(true)
    view.extend Alchemy::Admin::NavigationHelper
  end

  subject(:render_partial) do
    render partial: "alchemy/admin/partials/main_navigation_entry",
      locals: {alchemy_module: alchemy_module, navigation: navigation}
  end

  it "renders navigation with data attribute" do
    render_partial

    expect(rendered).to have_selector('alchemy-main-navi-entry[data-turbo="false"]')
  end

  context "with no data attribute" do
    let(:alchemy_module) do
      {
        engine_name: "alchemy",
        name: "what_a_name",
        navigation: {
          controller: "alchemy/admin/pages",
          action: "index",
          name: "Pages",
          image: "alchemy/alchemy-logo.svg",
          sub_navigation: []
        }
      }.with_indifferent_access
    end

    it "renders navigation without data attribute" do
      render_partial

      expect(rendered).not_to have_selector('alchemy-main-navi-entry[data-turbo="false"]')
    end
  end
end
