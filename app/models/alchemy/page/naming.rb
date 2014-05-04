module Alchemy
  module Page::Naming

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
        uniqueness: {scope: [:language_id, :layoutpage], if: 'urlname.present?'},
        exclusion:  {in: RESERVED_URLNAMES},
        length:     {minimum: 3, if: 'urlname.present?'},
        format:     {with: /\A[:\.\w\-+_\/\?&%;=]*\z/, if: :redirects_to_external?},
        presence:   {if: :redirects_to_external?}

      before_save :set_title, :if => 'title.blank?', :unless => proc { systempage? || redirects_to_external? }
      after_update(:if => proc { Config.get(:url_nesting) && (urlname_changed? || visible_changed?) }) do
        self.reload
        self.descendants.map(&:update_urlname!)
      end
      after_move :update_urlname!, :if => proc { Config.get(:url_nesting) }
    end

    # Returns true if name or urlname has changed.
    def renamed?
      name_changed? || urlname_changed?
    end

    # Makes a slug of all ancestors urlnames including mine and delimit them be slash.
    # So the whole path is stored as urlname in the database.
    def update_urlname!
      names = ancestors.visible.contentpages.where(language_root: nil).map(&:slug).compact
      new_urlname = (names << slug).join('/')
      if urlname != new_urlname
        legacy_urls.create(urlname: urlname)
      end
      update_column(:urlname, new_urlname)
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

    private

    # Sets the urlname to a url friendly slug.
    # Either from name, or if present, from urlname.
    # If url_nesting is enabled the urlname contains the whole path.
    def set_urlname
      if Config.get(:url_nesting)
        url_name = [
          parent.nil? || parent.language_root? ? nil : parent.urlname,
          convert_url_name((urlname.blank? ? name : slug))
        ].compact.join('/')
      else
        url_name = convert_url_name((urlname.blank? ? name : urlname))
      end
      write_attribute :urlname, url_name
    end

    def set_title
      write_attribute :title, name
    end

    # Converts the given name into an url friendly string.
    #
    # Names shorter than 3 will be filled up with dashes,
    # so it does not collidate with the language code.
    #
    def convert_url_name(name)
      url_name = convert_to_urlname(name)
      if url_name.length < 3
        ('-' * (3 - url_name.length)) + url_name
      else
        url_name
      end
    end
  end
end
