# frozen_string_literal: true

# Alchemy url helpers
#
# This helper is included within alchemy/pages_helper
#
module Alchemy
  module UrlHelper
    # Returns the path for rendering an alchemy page
    def show_alchemy_page_path(page, optional_params = {})
      alchemy.show_page_path(show_page_path_params(page, optional_params))
    end

    # Returns the url for rendering an alchemy page
    def show_alchemy_page_url(page, optional_params = {})
      alchemy.show_page_url(show_page_path_params(page, optional_params))
    end

    # Returns the correct params-hash for passing to show_page_path
    def show_page_path_params(page, optional_params = {})
      raise ArgumentError, 'Page is nil' if page.nil?
      url_params = {urlname: page.urlname}.update(optional_params)
      prefix_locale? ? url_params.update(locale: page.language_code) : url_params
    end

    # Returns the path for downloading an alchemy attachment
    def download_alchemy_attachment_path(attachment)
      alchemy.download_attachment_path(attachment, attachment.urlname)
    end

    # Returns the url for downloading an alchemy attachment
    def download_alchemy_attachment_url(attachment)
      alchemy.download_attachment_url(attachment, attachment.urlname)
    end

    # Returns the full url containing host, page and anchor for the given element
    def full_url_for_element(element)
      "#{current_server}/#{element.page.urlname}##{element_dom_id(element)}"
    end
  end
end
