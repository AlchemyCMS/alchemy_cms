class ErrorsController < ApplicationController
  def status_404
    render :text => "custom error handling"
  end
end