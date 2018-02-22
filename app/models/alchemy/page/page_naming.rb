# frozen_string_literal: true

module Alchemy
  module Page::PageNaming
    extend ActiveSupport::Concern
    include NameConversions
    RESERVED_URLNAMES = %w(admin messages new)

    included do
      before_validation :set_urlname,
        if: :renamed?,
        unless: -> { systempage? || redirects_to_external? || name.blank? }

      validates :name,
        presence: true
      validates :urlname,
        uniqueness: {scope: [:language_id, :layoutpage], if: -> { urlname.present? }},
        exclusion:  {in: RESERVED_URLNAMES},
        length:     {minimum: 3, if: -> { urlname.present? }},
        format:     {with: /\A[:\.\w\-+_\/\?&%;=]*\z/, if: :redirects_to_external?}
      validates :urlname,
        on: :update,
        presence: {if: :redirects_to_external?}

      before_save :set_title,
        unless: -> { systempage? || redirects_to_external? },
        if: -> { title.blank? }

      after_update :update_descendants_urlnames,
        if: :should_update_descendants_urlnames?

      after_move :update_urlname!,
        if: -> { Config.get(:url_nesting) },
        unless: :redirects_to_external?
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
      urlname.to_s.split('/').last
    end

    # Returns an urlname prefixed with http://, if no protocol is given
    def external_urlname
      return urlname if urlname =~ /\A(\/|[a-z]+:\/\/)/
      "http://#{urlname}"
    end

    # Returns an array of visible/non-language_root ancestors.
    def visible_ancestors
      return [] unless parent
      if new_record?
        parent.visible_ancestors.tap do |base|
          base.push(parent) if parent.visible?
        end
      else
        ancestors.visible.contentpages.where(language_root: nil).to_a
      end
    end

    private

    def should_update_descendants_urlnames?
      return false if !Config.get(:url_nesting)
      if active_record_5_1?
        saved_change_to_urlname? || saved_change_to_visible?
      else
        urlname_changed? || visible_changed?
      end
    end

    def update_descendants_urlnames
      reload
      descendants.each do |descendant|
        next if descendant.redirects_to_external?
        descendant.update_urlname!
      end
    end

    # Sets the urlname to a url friendly slug.
    # Either from name, or if present, from urlname.
    # If url_nesting is enabled the urlname contains the whole path.
    def set_urlname
      if Config.get(:url_nesting)
        value = slug
      else
        value = urlname
      end
      self[:urlname] = nested_url_name(value)
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
        ('-' * (3 - url_name.length)) + url_name
      else
        url_name
      end
    end

    def nested_url_name(value)
      (ancestor_slugs << convert_url_name(value)).join('/')
    end

    # Slugs of all visible/non-language_root ancestors.
    # Returns [], if there is no parent, the parent is
    # the root page itself, or url_nesting is off.
    def ancestor_slugs
      return [] if !Config.get(:url_nesting) || parent.nil? || parent.root?
      visible_ancestors.map(&:slug).compact
    end
  end
end
