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

      # All visible pages
      #
      scope :visible, -> { where(visible: true) }

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
          language_code: Language.published.pluck(:language_code)
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
      scope :contentpages, -> {
        where(layoutpage: [false, nil]).where(Page.arel_table[:parent_id].not_eq(nil))
      }

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

      # All pages for xml sitemap
      #
      scope :sitemap, -> { from_current_site.published.contentpages.where(sitemap: true) }
    end

    module ClassMethods
      # All public pages
      #
      def published
        where("#{table_name}.public_on <= :time AND " \
              "(#{table_name}.public_until IS NULL " \
              "OR #{table_name}.public_until >= :time)", time: Time.current)
      end

      # All not public pages
      #
      def not_public
        where("#{table_name}.public_on IS NULL OR " \
              "#{table_name}.public_on >= :time OR " \
              "#{table_name}.public_until <= :time", time: Time.current)
      end
    end
  end
end
