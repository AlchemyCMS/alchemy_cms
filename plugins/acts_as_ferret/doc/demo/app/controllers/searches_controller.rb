class SearchesController < ApplicationController

  def search
    @search = Search.new params[:q], params[:page]
    @results = @search.run if @search.valid?
  end

end
