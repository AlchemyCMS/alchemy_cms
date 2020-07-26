# frozen_string_literal: true

module Alchemy
  # Handles page redirect urls
  #
  # Lots of reasons exist to redirect to another URL than the requested one.
  # These module holds the logic behind these needs.
  #
  module PageRedirects
    extend ActiveSupport::Concern

    private

    # Returns an URL to redirect the request to.
    #
    # == Lookup:
    #
    # 1. If the current page URL has no locale prefixed, but we should have one,
    #    we return the prefixed URL.
    # 2. If no redirection is needed returns nil.
    #
    # @return String
    # @return NilClass
    #
    def redirect_url
      @_redirect_url ||= locale_prefixed_url || nil
    end

    def locale_prefixed_url
      return unless locale_prefix_missing?

      page_redirect_url(locale: Language.current.code)
    end

    # Page url with or without locale while keeping all additional params
    def page_redirect_url(options = {})
      options = {
        locale: prefix_locale? ? @page.language_code : nil,
        urlname: @page.urlname,
      }.merge(options)

      alchemy.show_page_path additional_params.merge(options)
    end

    def default_locale?
      Language.current.code.to_sym == ::I18n.default_locale.to_sym
    end

    def locale_prefix_missing?
      multi_language? && params[:locale].blank? && !default_locale?
    end
  end
end
