require 'spec_helper'

describe Alchemy::Admin::LanguagesController do
  before do
    authorize_user(:as_admin)
  end

  describe "#index" do
    context "with multiple sites" do
      let!(:default_site_language) do
        create(:alchemy_language)
      end

      let!(:site_2) do
        create(:alchemy_site, host: 'another-site.com')
      end

      let!(:site_2_language) do
        site_2.default_language
      end

      it 'only shows languages from current site' do
        alchemy_get :index
        expect(assigns(:languages)).to include(default_site_language)
        expect(assigns(:languages)).to_not include(site_2_language)
      end
    end

    context "editor users" do
      before do
        authorize_user(:as_editor)
      end

      it "should be able to index language" do
        alchemy_get :index
        expect(response).to render_template(:index)
      end
    end
  end

  describe "#new" do
    context "when default_language.page_layout is set" do
      before do
        stub_alchemy_config(:default_language, {'page_layout' => "new_standard"})
      end

      it "uses it as page_layout-default for the new language" do
        alchemy_get :new
        expect(assigns(:language).page_layout).to eq("new_standard")
      end
    end

    context "when default_language is not configured" do
      before do
        stub_alchemy_config(:default_language, nil)
      end

      it "falls back to default database value." do
        alchemy_get :new
        expect(assigns(:language).page_layout).to eq("intro")
      end
    end

    context "when default language page_layout is not configured" do
      before do
        stub_alchemy_config(:default_language, {})
      end

      it "falls back to default database value." do
        alchemy_get :new
        expect(assigns(:language).page_layout).to eq("intro")
      end
    end
  end
end
