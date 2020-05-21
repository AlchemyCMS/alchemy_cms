# frozen_string_literal: true

module Alchemy
  module Page::PageNaming
    extend ActiveSupport::Concern
    include NameConversions
    RESERVED_URLNAMES = %w(admin messages new)

    included do
      before_validation :set_urlname,
        if: :renamed?,
        unless: -> { name.blank? }

      validates :name,
        presence: true
      validates :urlname,
        uniqueness: { scope: [:language_id, :layoutpage], if: -> { urlname.present? } },
        exclusion: { in: RESERVED_URLNAMES },
        length: { minimum: 3, if: -> { urlname.present? } }

      before_save :set_title,
        if: -> { title.blank? }

      after_update :update_descendants_urlnames,
        if: :saved_change_to_urlname?

      after_move :update_urlname!
    end

    # Returns true if name or urlname has changed.
    def renamed?
      name_changed? || urlname_changed?
    end

    # Makes a slug of all ancestors urlnames including mine and delimit them be slash.
    # So the whole path is stored as urlname in the database.
    def update_urlname!
      new_urlname = nested_url_name(slug)
      if urlname != new_urlname
        legacy_urls.create(urlname: urlname)
        update_column(:urlname, new_urlname)
      end
    end

    # Returns always the last part of a urlname path
    def slug
      urlname.to_s.split("/").last
    end

    # Returns an array of non-language_root ancestors.
    def non_root_ancestors
      return [] unless parent

      if new_record?
        parent.non_root_ancestors.tap do |base|
          base.push(parent) unless parent.language_root?
        end
      else
        ancestors.contentpages.where(language_root: nil).to_a
      end
    end

    private

    def update_descendants_urlnames
      reload
      descendants.each(&:update_urlname!)
    end

    # Sets the urlname to a url friendly slug.
    # Either from name, or if present, from urlname.
    # The urlname contains the whole path including parent urlnames.
    def set_urlname
      self[:urlname] = nested_url_name(slug)
    end

    def set_title
      self[:title] = name
    end

    # Converts the given name into an url friendly string.
    #
    # Names shorter than 3 will be filled up with dashes,
    # so it does not collidate with the language code.
    #
    def convert_url_name(value)
      url_name = convert_to_urlname(value.blank? ? name : value)
      if url_name.length < 3
        ("-" * (3 - url_name.length)) + url_name
      else
        url_name
      end
    end

    def nested_url_name(value)
      (ancestor_slugs << convert_url_name(value)).join("/")
    end

    # Slugs of all non-language_root ancestors.
    # Returns [], if there is no parent, the parent is
    # the root page itself.
    def ancestor_slugs
      return [] if parent.nil?

      non_root_ancestors.map(&:slug).compact
    end
  end
end
