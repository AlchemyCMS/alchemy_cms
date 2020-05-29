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
      ROOT_PATH = "/"

      def initialize(page)
        @page = page
        @language = @page.language
        @site = @language.site
      end

      def call
        return @page.urlname if @page.definition["redirects_to_external"]

        if @page.language_root?
          language_root_path
        elsif @site.languages.select(&:public?).length > 1
          page_path_with_language_prefix
        else
          page_path_with_leading_slash
        end
      end

      private

      def language_root_path
        @language.default? ? ROOT_PATH : language_path
      end

      def page_path_with_language_prefix
        @language.default? ? page_path : language_path + page_path
      end

      def page_path_with_leading_slash
        @page.language_root? ? ROOT_PATH : page_path
      end

      def language_path
        "/#{@page.language_code}"
      end

      def page_path
        "/#{@page.urlname}"
      end
    end
  end
end
