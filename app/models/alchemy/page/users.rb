module Alchemy
  module Page::Users
    
    extend ActiveSupport::Concern

    # Returns the name of the creator of this page.
    def creator
      @page_creator ||= User.find_by_id(creator_id)
      return I18n.t('unknown') if @page_creator.nil?
      @page_creator.name
    end

    # Returns the name of the last updater of this page.
    def updater
      @page_updater = User.find_by_id(updater_id)
      return I18n.t('unknown') if @page_updater.nil?
      @page_updater.name
    end

    # Returns the name of the user currently editing this page.
    def current_editor
      @current_editor = User.find_by_id(locked_by)
      return I18n.t('unknown') if @current_editor.nil?
      @current_editor.name
    end

    def locker
      User.find_by_id(self.locked_by)
    end

    def locker_name
      return I18n.t('unknown') if self.locker.nil?
      self.locker.name
    end

  end
end
