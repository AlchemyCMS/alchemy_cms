# frozen_string_literal: true

require "rails_helper"

module Alchemy
  describe Admin::LayoutpagesController do
    routes { Alchemy::Engine.routes }

    before(:each) do
      authorize_user(:as_admin)
    end

    describe "#index" do
      context "with no language present" do
        it "redirects to the languages admin" do
          get :index
          expect(response).to redirect_to(admin_languages_path)
        end
      end

      context "with a language present" do
        let!(:language) { create(:alchemy_language) }

        context "and layoutpages present" do
          let!(:layoutpages) { create_list(:alchemy_page, 2, :layoutpage, language: language) }

          it "should assign @layout_pages" do
            get :index
            expect(assigns(:layout_pages)).to match_array(layoutpages)
          end
        end

        it "should assign @languages" do
          get :index
          expect(assigns(:languages).first).to be_a(Language)
        end

        context "with multiple sites" do
          let!(:site_2) do
            create(:alchemy_site, host: "another-site.com")
          end

          context "if no language exists for the current site" do
            it "redirects to the languages admin" do
              get :index, session: { alchemy_site_id: site_2.id }
              expect(response).to redirect_to(admin_languages_path)
            end
          end

          context "if an language exists for the current site" do
            let!(:language) { create(:alchemy_language) }
            let!(:language_2) do
              create(:alchemy_language, site: site_2)
            end

            it "only shows languages from current site" do
              get :index, session: { alchemy_site_id: site_2.id }
              expect(assigns(:languages)).to_not include(language)
              expect(assigns(:languages)).to include(language_2)
            end
          end
        end
      end
    end
  end
end
