module Alchemy
  module Publishable
    extend ActiveSupport::Concern

    included do
      scope :draft, -> { Alchemy.config.publishable_resolver.draft(all) }
      scope :scheduled, -> { Alchemy.config.publishable_resolver.scheduled(all) }
      scope :published, ->(at: Current.preview_time) {
        Alchemy.config.publishable_resolver.published(all, at:)
      }

      validate do
        if public_on.present? && public_until.present?
          if public_until <= public_on
            errors.add(:public_until, :must_be_after_public_on)
          end
        end
      end
    end

    # Determines if this record is public
    #
    # @param at [DateTime] (Current.preview_time)
    # @returns Boolean
    def public?(at: Current.preview_time)
      publishable_resolver.public?(at:)
    end
    alias_method :public, :public?

    # Determines if this record has a future publication or expiration event
    #
    # @param at [DateTime] (Current.preview_time)
    # @returns Boolean
    def scheduled?(at: Current.preview_time)
      publishable_resolver.scheduled?(at:)
    end

    # Determines if this record is publishable
    #
    # @returns Boolean
    def publishable?
      publishable_resolver.publishable?
    end

    private

    def publishable_resolver
      Alchemy.config.publishable_resolver.new(self)
    end
  end
end
