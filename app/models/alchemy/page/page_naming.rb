# frozen_string_literal: true

module Alchemy
  class Page < BaseRecord
    module PageNaming
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

      # Sets the urlname to a url friendly slug.
      # Either from name, or if present, from urlname.
      # The urlname contains the whole path including parent urlnames.
      def set_urlname
        self[:urlname] = nested_url_name
      end

      def set_title
        self[:title] = name
      end

      # Converts the given name into an url friendly string.
      #
      # Names shorter than 3 will be filled up with dashes,
      # so it does not collidate with the language code.
      #
      def converted_url_name
        url_name = convert_to_urlname(slug.blank? ? name : slug)
        url_name.rjust(3, "-")
      end

      def nested_url_name
        if parent&.language_root?
          converted_url_name
        else
          [parent&.urlname, converted_url_name].compact.join("/")
        end
      end
    end
  end
end
