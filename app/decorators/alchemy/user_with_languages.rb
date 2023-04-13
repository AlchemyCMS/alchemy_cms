# frozen_string_literal: true

module Alchemy
  class UserWithLanguages < SimpleDelegator
    alias_method :user, :__getobj__

    def language_restriction_implemented?
      user.respond_to? :languages
    end

    def accessible_languages
      language_restriction_implemented? ? super : Alchemy::Language.all
    end

    def accessible_language_ids
      accessible_languages.pluck(:id)
    end

    def languages_restricted?
      !language_restriction_implemented? ||
        accessible_languages != Alchemy::Language.all
    end

    def accessible_site_ids
      accessible_languages.map(&:site_id).uniq
    end

    def accessible_sites
      Alchemy::Site.where(id: accessible_site_ids).order(:id)
    end

    def can_access_language?(language)
      accessible_languages.where(id: language.id).any?
    end
  end
end
