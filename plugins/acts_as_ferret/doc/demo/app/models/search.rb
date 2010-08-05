# search form model
class Search

  attr_reader :query

  def initialize(query, page)
    @query = query
    @page = page ? page.to_i : 1
  end

  def valid?
    !@query.blank?
  end

  # run the search
  def run
    Content.find_with_ferret @query, :page => @page, :per_page => 10, :sort => 'title', :lazy => true
  end
end
