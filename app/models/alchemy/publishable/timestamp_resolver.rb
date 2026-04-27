# frozen_string_literal: true

module Alchemy
  module Publishable
    # Default resolver for Publishable records.
    #
    # Uses the +public_on+ and +public_until+ timestamp columns to determine
    # whether a record is public, scheduled, or publishable.
    #
    # This class defines the interface that custom resolvers configured via
    # +Alchemy.config.publishable_resolver+ must implement.
    #
    class TimestampResolver
      class << self
        # Returns records without a +public_on+ date set.
        def draft(publishables)
          publishables.where(public_on: nil)
        end

        # Returns records with a +public_on+ date set.
        def scheduled(publishables)
          publishables.where.not(public_on: nil)
        end

        # Returns records that are public at the given time.
        def published(publishables, at:)
          scheduled(publishables)
            .where("#{publishables.table_name}.public_on <= :at", at:)
            .where(public_until: nil).or(
              publishables.where("#{publishables.table_name}.public_until > :at", at:)
            )
        end
      end

      def initialize(publishable)
        @publishable = publishable
      end

      # Determines if the record is public at the given time.
      def public?(at: Current.preview_time)
        already_public_for?(at:) && still_public_for?(at:)
      end

      # Determines if the record has a future publication or expiration event.
      def scheduled?(at: Current.preview_time)
        (publishable.public_on.present? && publishable.public_on > at) ||
          (publishable.public_until.present? && publishable.public_until > at)
      end

      # Determines if the record is publishable.
      #
      # A record is publishable if a +public_on+ timestamp is set and not
      # expired yet.
      def publishable?
        !publishable.public_on.nil? && still_public_for?
      end

      private

      attr_reader :publishable

      def already_public_for?(at:)
        !publishable.public_on.nil? && publishable.public_on <= at
      end

      def still_public_for?(at: Current.preview_time)
        publishable.public_until.nil? || publishable.public_until > at
      end
    end
  end
end
