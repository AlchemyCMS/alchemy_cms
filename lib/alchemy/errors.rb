# frozen_string_literal: true

# Custom error classes.
#
module Alchemy
  class CellDefinitionError < StandardError
    # Raised if no cell definition can be found.
  end

  class ContentDefinitionError < StandardError
    # Raised if no content definition can be found.
  end

  class DefaultLanguageNotFoundError < StandardError
    # Raised if no default language configuration can be found.
    def message
      "No default language configuration found!" \
        " Please ensure that you have a 'default_language' defined in Alchemy configuration file."
    end
  end

  class DefaultSiteNotFoundError < StandardError
    # Raised if no default site configuration can be found.
    def message
      "No default site configuration found!" \
        " Please ensure that you have a 'default_site' defined in Alchemy configuration file."
    end
  end

  class DefaultLanguageNotDeletable < StandardError
    # Raised if one tries to delete the default language.
    def message
      "Default language is not deletable!"
    end
  end

  class ElementDefinitionError < StandardError
    # Raised if element definition can not be found.
    def initialize(attributes)
      @name = attributes[:name]
    end

    def message
      "Element definition for #{@name} not found. Please check your elements.yml"
    end
  end

  class EssenceMissingError < StandardError
    # Raised if a content misses its essence.
    def message
      "Essence not found"
    end
  end

  # Raised if calling +image_file+ on a Picture object returns nil.
  class MissingImageFileError < StandardError; end

  # Raised if calling +image_file+ on a Picture object returns nil.
  class WrongImageFormatError < StandardError
    def initialize(image, requested_format)
      @image = image
      @requested_format = requested_format
    end

    def message
      allowed_filetypes = Alchemy::Picture.allowed_filetypes.map(&:upcase).to_sentence
      "Requested image format (#{@requested_format.inspect}) for #{@image.inspect} is not one of allowed filetypes (#{allowed_filetypes})."
    end
  end

  class NotMountedError < StandardError
    # Raised if Alchemy is not properly mounted in the apps routes file.
    def message
      "Alchemy mount point not found! Please run `bin/rake alchemy:mount'"
    end
  end

  class PictureInUseError < StandardError
    # Raised if the picture is still in use and can not be deleted.
  end

  class TinymceError < StandardError; end

  class UpdateServiceUnavailable < StandardError
    # Raised if no successful connection to GitHub was possible
    def message
      "The update service is temporarily unavailable!"
    end
  end

  class MissingActiveRecordAssociation < StandardError
    # Raised if a alchemy_resource_relation is defined without proper ActiveRecord association
    def message
      "You need to define proper ActiveRecord associations, if you want to use alchemy_resource_relations."
    end
  end

  class NoCurrentUserFoundError < StandardError
    # Raised if no current_user is found to authorize against.
    def message
      "You need to provide a current_user method in your ApplicationController that returns the current authenticated user."
    end
  end
end
