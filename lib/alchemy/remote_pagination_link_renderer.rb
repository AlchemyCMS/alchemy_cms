# This is for will_paginate
module Alchemy
  class RemotePaginationLinkRenderer < WillPaginate::LinkRenderer
    
    def prepare(collection, options, template)
      @remote = options.delete(:remote) || {}
      super
    end
    
  protected
    
    def page_link(page, text, attributes = {})
      @template.link_to(text, url_for(page), {:remote => true, :method => :get}.merge(@remote).merge(attributes))
    end
    
  end
end
