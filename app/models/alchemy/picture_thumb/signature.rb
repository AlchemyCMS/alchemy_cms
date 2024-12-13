# frozen_string_literal: true

module Alchemy
  class PictureThumb < BaseRecord
    class Signature
      # Returns a unique image process signature
      #
      # @param [Alchemy::PictureVariant]
      #
      # @return [String]
      def self.call(variant)
        steps_without_fetch = variant.image.steps.reject do |step|
          step.is_a?(::Dragonfly::Job::Fetch)
        end

        steps_with_id = [[variant.picture.id]] + steps_without_fetch
        job_string = steps_with_id.map(&:to_a).to_dragonfly_unique_s

        Digest::SHA1.hexdigest(job_string)
      end
    end
  end
end
