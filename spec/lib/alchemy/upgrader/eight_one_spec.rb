# frozen_string_literal: true

require "rails_helper"
require "alchemy/upgrader"

RSpec.describe Alchemy::Upgrader::EightOne do
  let(:upgrader) { Alchemy::Upgrader["8.1"] }

  describe "#migrate_page_metadata" do
    context "with no pages" do
      it "skips migration" do
        expect { upgrader.migrate_page_metadata }.not_to raise_error
      end
    end

    context "with pages" do
      let!(:page) do
        create(:alchemy_page).tap do |p|
          p.update_columns(
            title: "Page Title",
            meta_description: "Page description",
            meta_keywords: "page, keywords"
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

      context "with published page" do
        let!(:page) do
          create(:alchemy_page, :public).tap do |p|
            p.update_columns(
              title: "Published Title",
              meta_description: "Published description",
              meta_keywords: "published, keywords"
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
