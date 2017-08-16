# frozen_string_literal: true

module Alchemy
  module Page::PageUsers
    extend ActiveSupport::Concern

    # Returns the creator of this page.
    #
    def creator
      get_page_user(creator_id)
    end

    # Returns the last updater of this page.
    #
    def updater
      get_page_user(updater_id)
    end

    # Returns the user currently editing this page.
    #
    def locker
      get_page_user(locked_by)
    end

    # Returns the name of the creator of this page.
    #
    # If no creator could be found or associated user model
    # does not respond to +#name+ it returns +'unknown'+
    #
    def creator_name
      (creator && creator.try(:name)) || Alchemy.t('unknown')
    end

    # Returns the name of the last updater of this page.
    #
    # If no updater could be found or associated user model
    # does not respond to +#name+ it returns +'unknown'+
    #
    def updater_name
      (updater && updater.try(:name)) || Alchemy.t('unknown')
    end

    # Returns the name of the user currently editing this page.
    #
    # If no locker could be found or associated user model
    # does not respond to +#name+ it returns +'unknown'+
    #
    def locker_name
      (locker && locker.try(:name)) || Alchemy.t('unknown')
    end

    private

    def get_page_user(id)
      if Alchemy.user_class.respond_to? :primary_key
        Alchemy.user_class.try(:find_by, {Alchemy.user_class.primary_key => id})
      end
    end
  end
end
