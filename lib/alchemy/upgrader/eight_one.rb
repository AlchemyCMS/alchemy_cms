# frozen_string_literal: true

module Alchemy
  class Upgrader
    module EightOne
      def migrate_page_metadata
        desc "Migrating page metadata to page versions"

        pages_count = Alchemy::Page.count
        if pages_count == 0
          log "No pages found. Skipping.", :skip
          return
        end

        log "Found #{pages_count} pages to process."

        Alchemy::PageVersion.reset_column_information
        Alchemy::Page.reset_column_information

        migrated_count = 0
        Alchemy::PageVersion.includes(:page).find_each do |version|
          page = version.page
          next unless page

          version.update_columns(
            title: page.read_attribute(:title),
            meta_description: page.read_attribute(:meta_description),
            meta_keywords: page.read_attribute(:meta_keywords)
          )
          migrated_count += 1
        end

        log "Migrated metadata for #{migrated_count} page versions."

        todo <<~TEXT, "Page metadata migration complete"
          Page metadata (title, meta_description, meta_keywords) has been copied
          from pages to their page versions.

          The columns on the pages table are now deprecated but still present
          for backwards compatibility. They will be removed in a future version.

          New code should read metadata from page versions:
            - page.public_version.title (for public content)
            - page.draft_version.title (for editing)

          The page model provides convenience getters that delegate to
          public_version with a fallback to draft_version:
            - page.title
            - page.meta_description
            - page.meta_keywords
        TEXT
      end
    end
  end
end
