# frozen_string_literal: true

module Alchemy
  module Admin
    module CurrentLanguage
      extend ActiveSupport::Concern

      included do
        before_action unless: -> { Alchemy::Language.current }, only: :index do
          flash[:warning] = Alchemy.t('Please create a language first.')
          redirect_to admin_languages_path
        end
      end
    end
  end
end
