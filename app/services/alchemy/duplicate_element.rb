# frozen_string_literal: true

module Alchemy
  # Copies an element and all of its nested elements.
  #
  # Used to duplicate elements (e.g. when pasting from the clipboard or copying a page).
  class DuplicateElement
    include DuplicatesElements
  end
end
