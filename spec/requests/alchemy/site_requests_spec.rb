require 'spec_helper'

RSpec.describe 'Site requests' do
  context 'a site with host' do
    let!(:site) { create(:alchemy_site, :public, host: 'alchemy-cms.com') }

    let(:page) do
      Alchemy::Site.current = site
      root = create(:alchemy_page, :language_root, language: site.languages.last)
      create(:alchemy_page, :public, parent: root)
    end

    it 'loads this site by host' do
      get "http://#{site.host}/#{page.urlname}"
      expect(assigns(:current_alchemy_site).host).to eq(site.host)
    end

    context 'with site_id of another site' do
      let(:another_site) { Alchemy::Site.default }

      let(:page) do
        Alchemy::Site.current = another_site
        root = create(:alchemy_page, :language_root, language: another_site.languages.last)
        create(:alchemy_page, :public, parent: root)
      end

      context 'in params' do
        it 'loads another site by id' do
          get "http://#{site.host}/#{page.urlname}?site_id=#{another_site.id}"
          expect(assigns(:current_alchemy_site).id).to eq(another_site.id)
        end
      end

      context 'with site_id of another site in session' do
        it 'loads another site by id' do
          allow_any_instance_of(Alchemy::PagesController).to receive(:session) do
            {site_id: another_site.id}
          end
          get "http://#{site.host}/#{page.urlname}"
          expect(assigns(:current_alchemy_site).id).to eq(another_site.id)
        end
      end
    end
  end
end
