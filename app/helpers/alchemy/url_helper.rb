# Alchemy url helpers
#
# This helper is included within alchemy/pages_helper
#
module Alchemy
  module UrlHelper

    # Returns the path for rendering an alchemy page
    def show_alchemy_page_path(page, optional_params={})
      alchemy.show_page_path(show_page_path_params(page, optional_params))
    end

    # Returns the url for rendering an alchemy page
    def show_alchemy_page_url(page, optional_params={})
      alchemy.show_page_url(show_page_path_params(page, optional_params))
    end

    # This helper returns a path to picture for use inside a image_tag helper.
    #
    # Any additional options are passed to the url_helper, so you can add arguments to your url.
    #
    # Example:
    #
    #   <%= image_tag show_alchemy_picture_path(picture, :size => '320x200', :format => :png) %>
    #
    def show_alchemy_picture_path(picture, optional_params={})
      alchemy.show_picture_path(show_picture_path_params(picture, optional_params))
    end

    # This helper returns an url to picture for use inside a image_tag helper.
    #
    # Any additional options are passed to the url_helper, so you can add arguments to your url.
    #
    # Example:
    #
    #   <%= image_tag show_alchemy_picture_url(picture, :size => '320x200', :format => :png) %>
    #
    def show_alchemy_picture_url(picture, optional_params={})
      alchemy.show_picture_url(show_picture_path_params(picture, optional_params))
    end

    # Returns the correct params hash for passing to show_picture_path
    def show_picture_path_params(picture, optional_params={})
      {
        id: picture.id,
        name: picture.urlname,
        format: configuration(:image_output_format),
        sh: picture.security_token(optional_params)
      }.update(optional_params)
    end

    # Returns the correct params-hash for passing to show_page_path
    def show_page_path_params(page, optional_params={})
      raise ArgumentError, 'Page is nil' if page.nil?
      url_params = {:urlname => page.urlname}.update(optional_params)
      multi_language? ? url_params.update(:lang => page.language_code) : url_params
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
