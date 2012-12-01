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

    # This helper returns a path for use inside a link_to helper.
    #
    # You may pass a page_layout or an urlname.
    # Any additional options are passed to the url_helper, so you can add arguments to your url.
    #
    # Example:
    #
    #   <%= link_to '&raquo order now', page_path_for(:page_layout => 'orderform', :product_id => element.id) %>
    #
    def page_path_for(options={})
      return warning("No page_layout, or urlname given. I got #{options.inspect} ") if options[:page_layout].blank? && options[:urlname].blank?
      if options[:urlname].blank?
        page = Page.find_by_page_layout(options[:page_layout])
        if page.blank?
          warning("No page found for #{options.inspect} ")
          return
        end
        urlname = page.urlname
      else
        urlname = options[:urlname]
      end
      alchemy.show_page_path({:urlname => urlname, :lang => multi_language? ? session[:language_code] : nil}.merge(options.except(:page_layout, :urlname, :lang)))
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
      url_params = {
        :id => picture.id,
        :name => picture.urlname,
        :format => configuration(:image_output_format),
        :sh => picture.security_token(optional_params)
      }
      url_params.update(optional_params.update({:crop => optional_params[:crop] ? 'crop' : nil}))
    end

    # Returns the correct params-hash for passing to show_page_path
    def show_page_path_params(page, optional_params={})
      raise ArgumentError, 'Page is nil' if page.nil?
      url_params = {:level1 => nil, :level2 => nil, :level3 => nil, :urlname => page.urlname}
      url_params.update(optional_params)
      url_params.update(params_for_nested_url(page)) if configuration(:url_nesting)
      multi_language? ? url_params.update(:lang => page.language_code) : url_params
    end

  end
end
