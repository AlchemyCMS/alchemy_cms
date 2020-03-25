# frozen_string_literal: true

require 'rails_helper'

describe "alchemy/admin/partials/_main_navigation_entry.html.erb" do
  let(:alchemy_module) do
    {
      engine_name: 'alchemy',
      name: 'what_a_name',
      navigation: {
        controller: 'alchemy/admin/pages',
        action: 'index',
        name: 'Pages',
        image: 'alchemy/alchemy-logo.svg',
        data: { turbolinks: false },
        sub_navigation: []
      }
    }.with_indifferent_access
  end

  let(:navigation) { alchemy_module[:navigation] }

  before do
    allow(view).to receive(:navigation).and_return(navigation)
    allow(view).to receive(:alchemy_module).and_return(alchemy_module)
    allow(view).to receive(:can?).and_return(true)
    view.extend Alchemy::Admin::NavigationHelper
  end

  it "renders navigation with data attribute" do
    render

    expect(rendered).to have_selector('div[data-turbolinks="false"]')
  end

  context 'with no data attribute' do
    let(:alchemy_module) do
      {
        engine_name: 'alchemy',
        name: 'what_a_name',
        navigation: {
          controller: 'alchemy/admin/pages',
          action: 'index',
          name: 'Pages',
          image: 'alchemy/alchemy-logo.svg',
          sub_navigation: []
        }
      }.with_indifferent_access
    end

    it "renders navigation without data attribute" do
      render

      expect(rendered).not_to have_selector('div[data-turbolinks="false"]')
    end
  end
end
