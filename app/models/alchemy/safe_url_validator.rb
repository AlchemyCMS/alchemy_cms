# frozen_string_literal: true

module Alchemy
  # Validates that a url does not carry an executable scheme.
  #
  # Only schemes listed in +Alchemy.config.allowed_url_schemes+ pass. Urls
  # without a scheme (absolute and relative paths, anchors, queries and
  # protocol relative urls) pass as well, they cannot carry executable code.
  #
  #   validates_with Alchemy::SafeUrlValidator, attributes: [:url]
  #
  class SafeUrlValidator < ActiveModel::EachValidator
    SCHEME_REGEX = /\A(?<scheme>[a-z][a-z0-9+.-]*):/i

    # Browsers drop these before they parse a url, which makes "java\tscript:"
    # a working "javascript:" url. They have to go before the scheme is read.
    STRIPPED_CHARS = /[\u0000-\u0020]/

    def validate_each(record, attribute, value)
      return if value.blank?

      scheme = SCHEME_REGEX.match(value.to_s.gsub(STRIPPED_CHARS, ""))&.[](:scheme)&.downcase
      return if scheme.nil? || allowed_schemes.include?(scheme)

      record.errors.add(attribute, :invalid_url_scheme, scheme: scheme)
    end

    private

    def allowed_schemes
      Alchemy.config.allowed_url_schemes.map(&:downcase)
    end
  end
end
