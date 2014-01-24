module Alchemy
  module Touching

    # Touches the timestamps and userstamps
    #
    def touch
      # Using update here, because we want the touch call to bubble up to the page.
      update(touchable_attributes)
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
      return unless self.respond_to?(:contents)
      self.contents.update_all(touchable_attributes)
    end

    # If the model has a +touchable_pages+ association,
    # it updates all their timestamps.
    #
    # Used by +Alchemy::Element+
    #
    def touch_pages
      return unless self.respond_to?(:touchable_pages)
      self.touchable_pages.update_all(touchable_attributes)
    end

    # Returns the attributes hash for touching a model.
    #
    def touchable_attributes
      {updated_at: Time.now, updater_id: Alchemy.user_class.try(:stamper)}
    end
  end
end
