# frozen_string_literal: true

module Alchemy
  class EssenceHeadline < BaseRecord
    acts_as_essence

    after_initialize :set_level_and_size

    def preview_text(maxlength = 30)
      "H#{level}: #{body}"[0..maxlength - 1]
    end

    def level_options
      levels.map { |level| ["H#{level}", level] }
    end

    def size_options
      sizes.map { |size| ["H#{size}", size] }
    end

    private

    def content_settings
      content&.settings || {}
    end

    def levels
      content_settings.fetch(:levels, (1..6))
    end

    def sizes
      content_settings.fetch(:sizes, [])
    end

    def set_level_and_size
      self.level ||= levels.first
      self.size ||= sizes.first
    end
  end
end
