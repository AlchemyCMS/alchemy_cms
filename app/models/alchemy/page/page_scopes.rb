module Alchemy

  # ActiveRecord scopes for Alchemy::Page
  #
  module Page::PageScopes
    extend ActiveSupport::Concern

    included do

      # All layout pages
      #
      scope :layoutpages, -> { where(layoutpage: true) }

      # All locked pages
      #
      scope :locked, -> { where(locked: true) }

      # All pages locked by given user
      #
      scope :locked_by, ->(user) {
        if user.class.respond_to? :primary_key
          locked.where(locked_by: user.send(user.class.primary_key))
        end
      }

      # All not locked pages
      #
      scope :not_locked, -> { where(locked: false) }

      # All public pages
      #
      scope :published, -> { where(public: true) }

      # All not restricted pages
      #
      scope :not_restricted, -> { where(restricted: false) }

      # All restricted pages
      #
      scope :restricted, -> { where(restricted: true) }

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
      scope :flushable_layoutpages, -> {
        not_locked.layoutpages.where.not(parent_id: Page.unscoped.root.id)
      }

      # All searchable pages
      #
      scope :searchables, -> { not_restricted.published.contentpages }

      # All pages from +Alchemy::Site.current+
      #
      scope :from_current_site, -> {
        where(Language.table_name => {site_id: Site.current || Site.default}).joins(:language)
      }
    end
  end
end
