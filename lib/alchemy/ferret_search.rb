module Alchemy
  # Provides full text search methods in your controller
  #
  # === Usage
  #
  #   include Alchemy::FerretSearch
  #
  module FerretSearch

    # Adds a +before_filter+ to your controller
    #
    def self.included(controller)
      controller.send(:before_filter, :perform_search, :only => :show)
      controller.send(:helper_method, :find_search_result_page)
    end

    # Performs a full text search with +Ferret+.
    #
    # Gets invoked everytime 'query' is given in params.
    #
    # This method only sets the +@search_results+ instance variable.
    #
    # You have to redirect to the search result page within a search form.
    #
    # === Alchemy provides a handy helper for rendering the search form:
    #
    #  render_search_form
    #
    # === Note
    #
    # If in preview mode a fake search value "lorem" will be set.
    #
    # @see Alchemy::PagesHelper#render_search_form
    #
    def perform_search
      if @preview_mode && params[:query].blank?
        params[:query] = 'lorem'
      end
      return if params[:query].blank?
      @search_results = get_search_results
    end

    # Finds what is provided in "query" param with Ferret on EssenceText and EssenceRichtext
    #
    # @return [Array]
    #
    def get_search_results
      search_results = []
      %w(Alchemy::EssenceText Alchemy::EssenceRichtext).each do |e|
        search_results += e.constantize.includes(:contents => {:element => :page}).find_with_ferret(
          "*#{params[:query]}*",
          {:limit => :all},
          {:conditions => [
            'alchemy_pages.public = ? AND alchemy_pages.layoutpage = ? AND alchemy_pages.restricted = ? AND alchemy_pages.language_id = ?',
            true, false, false, session[:language_id]
          ]}
        )
      end
      if search_results.any?
        search_results.sort { |y, x| x.ferret_score <=> y.ferret_score }
      end
    end

    # A view helper that loads the search result page.
    #
    # === Raises a ActiveRecord::RecordNotFound error, if the page could not be found or is not published.
    #
    # @return [Alchemy::Page]
    #
    def find_search_result_page
      if searchresult_page_layout = PageLayout.get_all_by_attributes(:searchresults => true).first
        search_result_page = Page.published.where(
          :page_layout => searchresult_page_layout["name"],
          :language_id => session[:language_id]
        ).limit(1).first
      end
      if search_result_page.nil?
        logger.warn "\n++++++\nNo published search result page found. Please create one or publish your search result page.\n++++++\n"
      end
      search_result_page
    end

  end
end
