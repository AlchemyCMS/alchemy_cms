# frozen_string_literal: true

require "rails_helper"

describe Alchemy::Admin::LanguagesController do
  routes { Alchemy::Engine.routes }

  before do
    authorize_user(:as_admin)
  end

  describe "#index" do
    context "without a site" do
      it "redirects to the sites admin" do
        get :index
        expect(response).to redirect_to(admin_sites_path)
      end
    end

    context "with multiple sites" do
      let!(:default_site_language) do
        create(:alchemy_language)
      end

      let!(:site_2) do
        create(:alchemy_site, host: "another-site.com")
      end

      let!(:site_2_language) do
        site_2.default_language
      end

      it "only shows languages from current site" do
        get :index
        expect(assigns(:languages)).to include(default_site_language)
        expect(assigns(:languages)).to_not include(site_2_language)
      end
    end

    context "editor users" do
      let!(:site) { create(:alchemy_site) }

      before do
        authorize_user(:as_editor)
      end

      it "should be able to index language" do
        get :index
        expect(response).to render_template(:index)
      end
    end
  end

  describe "#new" do
   context "without a site" do
      it "redirects to the sites admin" do
        get :new
        expect(response).to redirect_to(admin_sites_path)
      end
   end

   context "with a site" do
     let!(:site) { create(:alchemy_site) }

     it "has default language's page_layout set" do
       get :new
       expect(assigns(:language).page_layout).
         to eq(Alchemy::Config.get(:default_language)["page_layout"])
     end
   end
  end

  describe "#create" do
    context "with valid params" do
      it "redirects to the pages admin" do
        post :create, params: {
          language: {
            name: "English",
            language_code: "en",
            frontpage_name: "Index",
            page_layout: "index",
            public: true,
            default: true,
            site_id: create(:alchemy_site),
          },
        }
        language = Alchemy::Language.last
        expect(response).to redirect_to admin_pages_path(language_id: language)
        expect(flash[:notice]).to eq("Language successfully created.")
      end
    end

    context "with invalid params" do
      it "shows the form again" do
        post :create, params: { language: { name: "" } }
        expect(response).to render_template(:new)
      end
    end
  end

  describe "#destroy" do
    let(:language) { create(:alchemy_language) }

    context "with pages attached" do
      let!(:page) { create(:alchemy_page, language: language) }

      it "returns with error message" do
        delete :destroy, params: { id: language.id }
        expect(response).to redirect_to admin_languages_path
        expect(flash[:warning]).to \
          eq("Pages are still attached to this language. Please remove them first.")
      end
    end

    context "without pages" do
      it "removes the language" do
        delete :destroy, params: { id: language.id }
        expect(response).to redirect_to admin_languages_path
        expect(flash[:notice]).to eq("Language successfully removed.")
      end
    end
  end

  describe "#switch" do
    subject(:switch) do
      get :switch, params: { language_id: language.id }
    end

    let(:language) { create(:alchemy_language, :klingon) }

    it "should store the current language in session" do
      switch
      expect(session[:alchemy_language_id]).to eq(language.id)
    end

    context "having a referer" do
      before do
        expect_any_instance_of(ActionDispatch::Request).to receive(:referer) do
          "/admin/pages"
        end
      end

      it "should redirect to location" do
        is_expected.to redirect_to(admin_pages_path)
      end
    end

    context "having no referer" do
      it "should redirect to layoutpages" do
        is_expected.to redirect_to(admin_dashboard_path)
      end
    end
  end
end
