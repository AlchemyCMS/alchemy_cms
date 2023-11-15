# frozen_string_literal: true

module Alchemy
  class PageMutex < BaseRecord
    class LockFailed < StandardError; end

    MAX_AGE = 300 # seconds

    belongs_to :page, class_name: "Alchemy::Page", optional: true

    scope :expired, -> { where(arel_table[:created_at].lteq(MAX_AGE.seconds.ago)) }

    def self.with_lock!(page)
      raise ArgumentError, "A page is necessary to lock it" if page.nil?

      # remove old expired page if it wasn't deleted before
      expired.where(page: page).delete_all

      begin
        page_mutex = create!(page: page)
      rescue ActiveRecord::RecordNotUnique
        error = LockFailed.new("Can't lock page #{page.id} twice!")
        logger.error error.inspect
        raise error
      end
      yield
    ensure
      page_mutex&.destroy
    end
  end
end
