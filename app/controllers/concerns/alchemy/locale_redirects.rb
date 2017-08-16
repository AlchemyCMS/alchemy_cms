# frozen_string_literal: true

module Alchemy
  # Handles locale redirects
  #
  # If the current URL has a locale prefix, but should not have one it redirects
  # to url without locale prefix.
  #
  # Situations we don't want a locale prefix:
  #
  # 1. If only one language is published
  # 2. If the requested locale is the current default locale
  #
  module LocaleRedirects
    extend ActiveSupport::Concern

    included do
      before_action :enforce_no_locale,
        if: :locale_prefix_not_allowed?,
        only: [:index, :show]
    end

    private

    # Redirects to requested action without locale prefixed
    def enforce_no_locale
      redirect_permanently_to additional_params.merge(locale: nil)
    end

    # Is the requested locale allowed?
    #
    # If Alchemy is not in multi language mode or the requested locale is the default locale,
    # then we want to redirect to a non prefixed url.
    #
    def locale_prefix_not_allowed?
      params[:locale].present? && !multi_language? ||
        params[:locale].presence == ::I18n.default_locale.to_s
    end
  end
end
