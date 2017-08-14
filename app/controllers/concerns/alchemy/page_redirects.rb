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
    # 1. If the page is not published and we have a published child,
    #    we return the url top that page. (Configurable through +redirect_to_public_child+).
    # 2. If the page layout of the page found has a controller and action configured,
    #    we return the url to that route. (Configure controller and action in `page_layouts.yml`).
    # 3. If the current page URL has no locale prefixed, but we should have one,
    #    we return the prefixed URL.
    # 4. If no redirection is needed returns nil.
    #
    # @return String
    # @return NilClass
    #
    def redirect_url
      @_redirect_url ||= public_child_redirect_url || controller_and_action_url ||
                         locale_prefixed_url || nil
    end

    def locale_prefixed_url
      return unless locale_prefix_missing?

      page_redirect_url(locale: Language.current.code)
    end

    def public_child_redirect_url
      return if @page.public?

      if configuration(:redirect_to_public_child)
        @page = @page.descendants.published.not_restricted.first
        @page ? page_redirect_url : page_not_found!
      else
        page_not_found!
      end
    end

    def controller_and_action_url
      return unless @page.has_controller?

      main_app.url_for(@page.controller_and_action)
    end

    # Page url with or without locale while keeping all additional params
    def page_redirect_url(options = {})
      options = {
        locale: prefix_locale? ? @page.language_code : nil,
        urlname: @page.urlname
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
