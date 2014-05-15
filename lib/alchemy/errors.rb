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
    # Raised if no default language can be found.
    def message
      "No default language found. Have you run the rake alchemy:db:seed task?"
    end
  end

  class ElementDefinitionError < StandardError
    # Raised if element definition can not be found.
  end

  class EssenceMissingError < StandardError
    # Raised if a content misses its essence.
    def message
      "Essence not found"
    end
  end

  class MissingImageFileError < StandardError
    # Raised if calling +image_file+ on a Picture object returns nil.
  end

  class PageLayoutDefinitionError < StandardError
    # Raised if page_layout definition can not be found.
  end

  class PictureInUseError < StandardError
    # Raised if the picture is still in use and can not be deleted.
  end

  class TinymceError < StandardError; end

  class UpdateServiceUnavailable < StandardError
    # Raised it no succesful connection to GitHub was possible
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
