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
      super(text, target, attributes)
    end

  end
end
