# frozen_string_literal: true

module Alchemy
  class Page < BaseRecord
    module PageNaming
      extend ActiveSupport::Concern
      include NameConversions

      RESERVED_URLNAMES = %w[admin messages new]

      included do
        before_validation :set_urlname,
          if: :renamed?,
          unless: -> { name.blank? }

        validates :name,
          presence: true, uniqueness: {scope: [:parent_id], case_sensitive: false, unless: -> { parent_id.nil? }}
        validates :urlname,
          uniqueness: {scope: [:language_id, :layoutpage], if: -> { urlname.present? }, case_sensitive: false},
          exclusion: {in: RESERVED_URLNAMES}

        before_save :set_title,
          if: -> { title.blank? }

        after_update :update_descendants_urlnames,
          if: :saved_change_to_urlname?

        before_save :destroy_obsolete_legacy_urls, if: :renamed?

        after_move :update_urlname!
      end

      # Returns true if name or urlname has changed.
      def renamed?
        name_changed? || urlname_changed?
      end

      # Makes a slug of all ancestors urlnames including mine and delimit them be slash.
      # So the whole path is stored as urlname in the database.
      def update_urlname!
        new_urlname = nested_url_name
        if urlname != new_urlname
          legacy_urls.create(urlname: urlname)
          update_column(:urlname, new_urlname)
        end
      end

      # Returns always the last part of a urlname path
      def slug
        urlname.to_s.split("/").last
      end

      private

      def update_descendants_urlnames
        reload
        descendants.each(&:update_urlname!)
      end

      def destroy_obsolete_legacy_urls
        obsolete_legacy_urls = legacy_urls.select { |legacy_url| legacy_url.urlname == urlname }
        legacy_urls.destroy(obsolete_legacy_urls)
      end

      # Sets the urlname to a url friendly slug.
      # Either from name, or if present, from urlname.
      # The urlname contains the whole path including parent urlnames.
      def set_urlname
        self[:urlname] = nested_url_name
      end

      def set_title
        self[:title] = name
      end

      # Returns the full nested urlname.
      #
      def nested_url_name
        converted_url_name = convert_to_urlname(slug.blank? ? name : slug)
        if parent&.language_root?
          converted_url_name
        else
          [parent&.urlname, converted_url_name].compact.join("/")
        end
      end
    end
  end
end
