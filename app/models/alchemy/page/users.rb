module Alchemy
  module Page::Users

    extend ActiveSupport::Concern

    # Returns the name of the creator of this page.
    def creator_name
      return I18n.t('unknown') if creator.nil?
      creator.name
    end

    # Returns the name of the last updater of this page.
    def updater_name
      return I18n.t('unknown') if updater.nil?
      updater.name
    end

    # Returns the name of the user currently editing this page.
    def locker_name
      return I18n.t('unknown') if locker.nil?
      locker.name
    end

  end
end
