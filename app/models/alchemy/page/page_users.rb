module Alchemy
  module Page::PageUsers
    extend ActiveSupport::Concern

    # Returns the name of the creator of this page.
    #
    # If no creator could be found or associated user model
    # does not respond to +#name+ it returns +'unknown'+
    #
    def creator_name
      (creator && creator.respond_to?(:name) ? creator.name : nil) || I18n.t('unknown')
    end

    # Returns the name of the last updater of this page.
    #
    # If no updater could be found or associated user model
    # does not respond to +#name+ it returns +'unknown'+
    #
    def updater_name
      (updater && updater.respond_to?(:name) ? updater.name : nil) || I18n.t('unknown')
    end

    # Returns the name of the user currently editing this page.
    #
    # If no locker could be found or associated user model
    # does not respond to +#name+ it returns +'unknown'+
    #
    def locker_name
      (locker && locker.respond_to?(:name) ? locker.name : nil) || I18n.t('unknown')
    end

  end
end
