# frozen_string_literal: true

# Alchemy url helpers
#
# This helper is included within alchemy/pages_helper
#
module Alchemy
  module UrlHelper
    # Returns the path for rendering an alchemy page
    def show_alchemy_page_path(page, optional_params = {})
      page.url_path(optional_params)
    end

    # Returns the url for rendering an alchemy page
    def show_alchemy_page_url(page, optional_params = {})
      request.base_url + page.url_path(optional_params)
    end

    # Returns the path for downloading an alchemy attachment
    def download_alchemy_attachment_path(attachment)
      alchemy.download_attachment_path(attachment, attachment.slug)
    end

    # Returns the url for downloading an alchemy attachment
    def download_alchemy_attachment_url(attachment)
      alchemy.download_attachment_url(attachment, attachment.slug)
    end
  end
end
