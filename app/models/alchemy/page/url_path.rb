# frozen_string_literal: true

module Alchemy
  class Page
    # = The url_path for this page
    #
    # Use this to build relative links to this page
    #
    # It takes several circumstances into account:
    #
    # 1. It returns just a slash for language root pages of the default langauge
    # 2. It returns a url path with a leading slash for regular pages
    # 3. It returns a url path with a leading slash and language code prefix for pages not having the default language
    # 4. It returns a url path with a leading slash and the language code for language root pages of a non-default language
    #
    # == Examples
    #
    # Using Rails' link_to helper
    #
    #     link_to page.url
    #
    class UrlPath
      def initialize(page, optional_params = {}, wildcard_params: {})
        @page = page
        @language = @page.language
        @site = @language.site
        @optional_params = optional_params
        @wildcard_params = wildcard_params
      end

      def call
        path = if @page.language_root?
          language_root_path
        elsif @site.languages.count(&:public?) > 1
          page_path_with_language_prefix
        else
          page_path_with_leading_slash
        end

        if @optional_params.present?
          uri = URI(path)
          uri.query = @optional_params.to_query
          uri.to_s
        else
          path
        end
      end

      private

      def language_root_path
        @language.default? ? root_path : language_path
      end

      def page_path_with_language_prefix
        @language.default? ? page_path : language_path + page_path
      end

      def page_path_with_leading_slash
        @page.language_root? ? root_path : page_path
      end

      def language_path
        "#{root_path}#{@page.language_code}"
      end

      def page_path
        urlname = @page.urlname
        @wildcard_params.each do |key, val|
          urlname = urlname.gsub(":#{key}", val.to_s)
        end
        "#{root_path}#{urlname}"
      end

      def root_path
        Engine.routes.url_helpers.root_path
      end
    end
  end
end
