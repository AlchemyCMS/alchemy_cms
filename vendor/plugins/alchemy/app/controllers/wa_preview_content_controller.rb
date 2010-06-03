class WaPreviewContentController < ApplicationController
  
  before_filter :default_locale

  def default_locale
    FastGettext.locale = current_user.language unless current_user == :false || current_user.blank?
  end

  def show_content
    @partial = params[:for][:controller] + "_" + params[:for][:action]
  end
  
end
