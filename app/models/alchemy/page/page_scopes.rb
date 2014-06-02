module Alchemy

  # ActiveRecord scopes for Alchemy::Page
  #
  module Page::PageScopes
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
      scope :all_locked, -> { where(locked: true) }

      # All pages locked by given user
      #
      scope :all_locked_by, ->(user) {
        all_locked.where(locked_by: user.id)
      }

      # All not locked pages
      #
      scope :not_locked, -> { where(locked: false) }

      # All visible pages
      #
      scope :visible, -> { where(visible: true) }

      # All public pages
      #
      scope :published, -> { where(public: true) }

      # All not restricted pages
      #
      scope :not_restricted, -> { where(restricted: false) }

      # All restricted pages
      #
      scope :restricted, -> { where(restricted: true) }

      # All pages that are a published language root
      #
      scope :public_language_roots, -> {
        published.language_roots.where(
          language_code: Language.published.pluck(:code)
        )
      }

      # Last 5 pages that where recently edited by given user
      #
      scope :all_last_edited_from, ->(user) {
        where(updater_id: user.id).order('updated_at DESC').limit(5)
      }

      # Returns all pages that have the given +language_id+
      #
      scope :with_language, ->(language_id) {
        where(language_id: language_id)
      }

      # Returns all content pages.
      #
      scope :contentpages, -> { where(layoutpage: [false, nil]).where(Page.arel_table[:parent_id].not_eq(nil)) }

      # Returns all public contentpages that are not locked.
      #
      # Used for flushing all pages caches at once.
      #
      scope :flushables, -> { not_locked.published.contentpages }

      # All searchable pages
      #
      scope :searchables, -> { not_restricted.published.contentpages }

      # All pages from +Alchemy::Site.current+
      #
      scope :from_current_site, -> {
        where(alchemy_languages: {site_id: Site.current || Site.default}).joins(:language)
      }

      # All pages for xml sitemap
      #
      scope :sitemap, -> { from_current_site.published.contentpages.where(sitemap: true) }
    end

  end
end
