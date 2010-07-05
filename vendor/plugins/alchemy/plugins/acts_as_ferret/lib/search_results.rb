module ActsAsFerret

  # decorator that adds a total_hits accessor and will_paginate compatible 
  # paging support to search result arrays
  class SearchResults < ActsAsFerret::BlankSlate
    reveal :methods
    attr_reader :current_page, :per_page, :total_hits, :total_pages
    alias total_entries total_hits  # will_paginate compatibility
    alias page_count total_pages    # will_paginate backwards compatibility

    def initialize(results, total_hits, current_page = 1, per_page = nil)
      @results = results
      @total_hits = total_hits
      @current_page = current_page
      @per_page = (per_page || total_hits)
      @total_pages   = @per_page > 0 ? (@total_hits / @per_page.to_f).ceil : 0
    end

    def method_missing(symbol, *args, &block)
      @results.send(symbol, *args, &block)
    end

    def respond_to?(name)
      methods.include?(name.to_s) || @results.respond_to?(name)
    end


    # code from here on was directly taken from will_paginate's collection.rb

    # Current offset of the paginated collection. If we're on the first page,
    # it is always 0. If we're on the 2nd page and there are 30 entries per page,
    # the offset is 30. This property is useful if you want to render ordinals
    # besides your records: simply start with offset + 1.
    #
    def offset
      (current_page - 1) * per_page
    end

    # current_page - 1 or nil if there is no previous page
    def previous_page
      current_page > 1 ? (current_page - 1) : nil
    end

    # current_page + 1 or nil if there is no next page
    def next_page
      current_page < total_pages ? (current_page + 1) : nil
    end
  end

end
