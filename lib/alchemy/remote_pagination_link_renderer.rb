# A custom WillPaginate LinkRenderer Class for rendering remote links.
require 'will_paginate/view_helpers/action_view'

module Alchemy
  class RemotePaginationLinkRenderer < WillPaginate::ActionView::LinkRenderer

    def prepare(collection, options, template)
      @remote = options.delete(:remote) || {}
      super(collection, options, template)
    end

  private

    def link(text, target, attributes = {})
      attributes["data-remote"] = "true" if @remote
      @template.link_to(text.to_s.html_safe, clean_params.merge({:page => target}), attributes)
    end

    # Cleaning params from some post data, if we uploaded a picture
    def clean_params
      @template.params.delete_if { |k, v|
        ['Filename', 'Upload', 'Filedata', 'authenticity_token', Rails.configuration.session_options[:key]].include?(k)
      }
      if @template.params[:options].is_a?(String)
        @template.params[:options] = Rack::Utils.parse_query(@template.params[:options])
      end
      @template.params
    end

  end
end
