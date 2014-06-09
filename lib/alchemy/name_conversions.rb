# encoding: utf-8

module Alchemy
  # Provides methods for converting names into urlnames and vice versa.
  #
  module NameConversions

    # Converts a given name into url save and readable urlanme.
    # Uses rails parameterize, but converts german umlauts before.
    #
    # @returns String
    def convert_to_urlname(name)
      name
        .gsub(/[äÄ]/, 'ae')
        .gsub(/[üÜ]/, 'ue')
        .gsub(/[öÖ]/, 'oe')
        .gsub(/[ß]/, 'ss')
        .parameterize
    end

    # Converts a filename and suffix into a human readable name.
    #
    def convert_to_humanized_name(name, suffix)
      name.gsub(/\.#{::Regexp.quote(suffix)}$/i, '').gsub(/_/, ' ').strip
    end

  end
end
