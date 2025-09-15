# frozen_string_literal: true

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
        .gsub(/[äÄ]/, "ae")
        .gsub(/[üÜ]/, "ue")
        .gsub(/[öÖ]/, "oe")
        .gsub(/ß/, "ss")
        .parameterize
    end

    # Converts a filename and suffix into a human readable name.
    #
    def convert_to_humanized_name(name, suffix)
      name.gsub(/\.#{::Regexp.quote(suffix)}$/i, "").tr("_", " ").strip
    end

    # Sanitizes a given filename by removing directory traversal attempts and HTML entities.
    def sanitized_filename(file_name)
      file_name = File.basename(file_name)
      CGI.escapeHTML(file_name)
    end
  end
end
