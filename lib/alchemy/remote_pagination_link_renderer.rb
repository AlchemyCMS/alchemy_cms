# This is for will_paginate
module Alchemy
  
  class RemotePaginationLinkRenderer < WillPaginate::LinkRenderer
  
    def prepare(collection, options, template)
      @remote = options.delete(:remote) || {}
      super
    end
  
  protected
  
    def page_link(page, text, attributes = {})
      @template.link_to_remote(text, {:url => url_for(page), :method => :get}.merge(@remote), attributes)
    end
  
  end
  
end
