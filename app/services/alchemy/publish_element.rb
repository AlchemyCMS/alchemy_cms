# frozen_string_literal: true

module Alchemy
  # Copies a publishable element onto a public page version.
  #
  # Copies only the source element's *publishable* nested elements, since
  # non-publishable elements must not appear on the public version.
  #
  # This is the default +Alchemy.config.element_publisher+.
  class PublishElement
    include DuplicatesElements

    protected

    def nested_elements
      repository.children_of(source_element).publishable
    end
  end
end
