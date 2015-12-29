module Alchemy
  module PageRedirects

    private

    # = Page redirect url
    #
    # Lots of reasons exist to redirect to another url, then the requested one.
    # These module holds the logic behind this needs.
    #
    # If no redirect is needed returns nil.
    #
    # @return String
    # @return NilClass
    #
    def redirect_url
      @_redirect_url ||= legacy_page_redirect_url || raise_page_not_found ||
        public_child_redirect_url || controller_and_action_url || locale_prefixed_url || nil
    end

    # Use the bare minimum to redirect to page
    # Don't use query string of legacy urlname
    # This drops the given query string.
    def legacy_page_redirect_url
      return unless redirect_to_legacy_url?

      page = last_legacy_url.page
      return unless page

      alchemy.show_page_path(
        locale: prefix_locale? ? page.language_code : nil,
        urlname: page.urlname
      )
    end

    def raise_page_not_found
      page_not_found! if @page.blank?
    end

    def locale_prefixed_url
      return unless locale_prefix_missing?

      page_redirect_url(locale: Language.current.code)
    end

    def public_child_redirect_url
      return unless redirect_to_public_child?

      @page = @page.self_and_descendants.published.not_restricted.first
      @page ? page_redirect_url : page_not_found!
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

    def legacy_urls
      # /slug/tree => slug/tree
      urlname = (request.fullpath[1..-1] if request.fullpath[0] == '/') || request.fullpath
      LegacyPageUrl.joins(:page).where(
        urlname: urlname,
        Page.table_name => {
          language_id: Language.current.id
        }
      )
    end

    def last_legacy_url
      @_last_legacy_url ||= legacy_urls.last
    end

    def default_locale?
      Language.current.code.to_sym == ::I18n.default_locale.to_sym
    end

    def locale_prefix_missing?
      multi_language? && params[:locale].blank? && !default_locale?
    end

    def redirect_to_legacy_url?
      (@page.nil? || request.format.nil?) && last_legacy_url
    end

    def redirect_to_public_child?
      configuration(:redirect_to_public_child) && !@page.public?
    end
  end
end
