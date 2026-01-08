# frozen_string_literal: true

require "rails_helper"
require "alchemy/upgrader"

RSpec.describe Alchemy::Upgrader::EightOne do
  let(:upgrader) { Alchemy::Upgrader["8.1"] }

  describe "#migrate_page_metadata" do
    context "when all page versions have metadata" do
      let!(:page) do
        create(:alchemy_page).tap do |p|
          p.draft_version.update_columns(
            title: "Existing Title",
            meta_description: "Existing description",
            meta_keywords: "existing, keywords"
          )
        end
      end

      it "skips migration" do
        expect { upgrader.migrate_page_metadata }.not_to raise_error
      end
    end

    context "with page versions without metadata" do
      let!(:page) do
        create(:alchemy_page).tap do |p|
          p.update_columns(
            title: "Page Title",
            meta_description: "Page description",
            meta_keywords: "page, keywords"
          )
          p.draft_version.update_columns(
            title: nil,
            meta_description: nil,
            meta_keywords: nil
          )
        end
      end

      it "copies metadata from page to all versions" do
        upgrader.migrate_page_metadata

        page.versions.each do |version|
          version.reload
          expect(version.title).to eq("Page Title")
          expect(version.meta_description).to eq("Page description")
          expect(version.meta_keywords).to eq("page, keywords")
        end
      end

      it "is idempotent" do
        upgrader.migrate_page_metadata
        page.draft_version.update_columns(title: "Modified Title")

        upgrader.migrate_page_metadata

        expect(page.draft_version.reload.title).to eq("Modified Title")
      end

      context "with published page" do
        let!(:page) do
          create(:alchemy_page, :public).tap do |p|
            p.update_columns(
              title: "Published Title",
              meta_description: "Published description",
              meta_keywords: "published, keywords"
            )
            p.versions.update_all(
              title: nil,
              meta_description: nil,
              meta_keywords: nil
            )
          end
        end

        it "copies metadata to both draft and public versions" do
          upgrader.migrate_page_metadata

          expect(page.draft_version.reload.title).to eq("Published Title")
          expect(page.public_version.reload.title).to eq("Published Title")
        end
      end
    end
  end
end
