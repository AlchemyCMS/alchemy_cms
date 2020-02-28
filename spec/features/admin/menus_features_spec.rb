# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Admin Menus Features", type: :system do
  before do
    authorize_user(:as_admin)
  end

  describe 'adding a new menu' do
    context 'on the index page' do
      let!(:default_site) { create(:alchemy_site, :default) }

      it 'creates menu' do
        visit alchemy.admin_nodes_path

        fill_in 'Name', with: 'Main Menu'
        click_button 'create'

        expect(page).to have_selector('.node_name', text: 'Main Menu')
      end
    end
  end

  describe 'adding a new menu' do
    context 'with multiple sites' do
      let!(:default_site) { create(:alchemy_site, :default) }
      let!(:site_2) { create(:alchemy_site, host: 'another-site.com') }
      let(:node) { Alchemy::Node.last }

      it 'creates menu for current site' do
        visit alchemy.new_admin_node_path

        fill_in 'Name', with: 'Main Menu'
        click_button 'create'

        expect(node.site_id).to eq(default_site.id)
      end
    end
  end
end
