# frozen_string_literal: true

module Alchemy
  # ActiveRecord scopes for Alchemy::Page
  #
  class Page < BaseRecord
    module PageScopes
      extend ActiveSupport::Concern

      included do
        # All language root pages
        #
        scope :language_roots, -> { where(language_root: true) }

        # All layout pages
        #
        scope :layoutpages, -> { where(layoutpage: true) }

        # All locked pages
        #
        scope :locked, -> { where.not(locked_at: nil).where.not(locked_by: nil) }

        # All pages locked by given user
        #
        scope :locked_by,
          ->(user) {
            if user.class.respond_to? :primary_key
              locked.where(locked_by: user.send(user.class.primary_key))
            end
          }

        # All not locked pages
        #
        scope :not_locked, -> { where(locked_at: nil, locked_by: nil) }

        # All not restricted pages
        #
        scope :not_restricted, -> { where(restricted: false) }

        # All restricted pages
        #
        scope :restricted, -> { where(restricted: true) }

        # All public pages
        #
        scope :published,
          -> {
            joins(:language, :versions).
              merge(Language.published).
              merge(PageVersion.public_on(Time.current))
          }

        # All pages that are a published language root
        #
        scope :public_language_roots,
          -> {
            published.language_roots.where(
              language_code: Language.published.pluck(:language_code),
            )
          }

        # Last 5 pages that where recently edited by given user
        #
        scope :all_last_edited_from,
          ->(user) {
            where(updater_id: user.id).order("updated_at DESC").limit(5)
          }

        # Returns all pages that have the given +language_id+
        #
        scope :with_language, ->(language_id) { where(language_id: language_id) }

        # Returns all content pages.
        #
        scope :contentpages, -> { where(layoutpage: [false, nil]) }

        # Returns all public contentpages that are not locked.
        #
        # Used for flushing all pages caches at once.
        #
        scope :flushables, -> { not_locked.published.contentpages }

        # Returns all layoutpages that are not locked.
        #
        # Used for flushing all pages caches at once.
        #
        scope :flushable_layoutpages, -> { not_locked.layoutpages }

        # All searchable pages
        #
        scope :searchables, -> { not_restricted.published.contentpages }

        # All pages from +Alchemy::Site.current+
        #
        scope :from_current_site,
          -> {
            where(Language.table_name => { site_id: Site.current || Site.default }).joins(:language)
          }

        # All pages for xml sitemap
        #
        scope :sitemap, -> { from_current_site.published.contentpages.where(sitemap: true) }
      end

      module ClassMethods
        # All pages that do not have any public version
        #
        def not_public(time = Time.current)
          where <<~SQL
            alchemy_pages.id NOT IN (
              SELECT alchemy_page_versions.page_id
              FROM alchemy_page_versions
              WHERE alchemy_page_versions.public_on <= '#{connection.quoted_date(time)}'
              AND (
                alchemy_page_versions.public_until IS NULL
                OR alchemy_page_versions.public_until >= '#{connection.quoted_date(time)}'
              )
            )
          SQL
        end
      end
    end
  end
end
