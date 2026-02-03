module Alchemy
  module Publishable
    extend ActiveSupport::Concern

    included do
      scope :draft, -> { where(public_on: nil) }
      scope :scheduled, -> { where.not(public_on: nil) }

      scope :published, ->(at: Time.current) {
        scheduled
          .where("#{table_name}.public_on <= :at", at:)
          .where(public_until: nil).or(
            where("#{table_name}.public_until > :at", at:)
          )
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
    # Takes the two timestamps +public_on+ and +public_until+
    # and returns true if the time given (+Time.current+ per default)
    # is in this timespan.
    #
    # @param time [DateTime] (Time.current)
    # @returns Boolean
    def public?(time = Time.current)
      already_public_for?(time) && still_public_for?(time)
    end
    alias_method :public, :public?

    def scheduled?
      public_on&.future? || public_until&.future?
    end

    # Determines if this record is publishable
    #
    # A record is publishable if a +public_on+ timestamp is set and not expired yet.
    #
    # @returns Boolean
    def publishable?
      !public_on.nil? && still_public_for?
    end

    # Determines if this record is already public for given time
    # @param time [DateTime] (Time.current)
    # @returns Boolean
    def already_public_for?(time = Time.current)
      !public_on.nil? && public_on <= time
    end

    # Determines if this record is still public for given time
    # @param time [DateTime] (Time.current)
    # @returns Boolean
    def still_public_for?(time = Time.current)
      public_until.nil? || public_until >= time
    end
  end
end
