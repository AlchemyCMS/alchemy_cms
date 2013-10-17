module Alchemy
  module Page::Users
    extend ActiveSupport::Concern

    # Returns the name of the creator of this page.
    #
    # If no creator could be found or associated user model
    # does not respond to +#name+ it returns +'unknown'+
    #
    def creator_name
      (creator && creator.try(:name)) || I18n.t('unknown')
    end

    # Returns the name of the last updater of this page.
    #
    # If no updater could be found or associated user model
    # does not respond to +#name+ it returns +'unknown'+
    #
    def updater_name
      (updater && updater.try(:name)) || I18n.t('unknown')
    end

    # Returns the name of the user currently editing this page.
    #
    # If no locker could be found or associated user model
    # does not respond to +#name+ it returns +'unknown'+
    #
    def locker_name
      (locker && locker.try(:name)) || I18n.t('unknown')
    end

  end
end
