# frozen_string_literal: true

module Alchemy
  module ContentTouching
    def self.included(base)
      base.after_update(:touch_contents)
    end

    private

    # If the model has a +contents+ association,
    # it updates all their timestamps.
    #
    # CAUTION: Only use on bottom to top releations,
    # e.g. +Alchemy::Picture+ or +Alchemy::Attachment+
    # not on top to bottom ones like +Alchemy::Element+.
    #
    def touch_contents
      return unless respond_to?(:contents)

      contents.update_all(updated_at: Time.current)
    end
  end
end
