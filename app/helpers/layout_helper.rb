# These helper methods can be called in your template to set variables to be used in the layout
# This module should be included in all views globally,
# to do so you may need to add this line to your ApplicationController
#   helper :layout
module LayoutHelper
  def title(page_title, show_title = true)
    @content_for_title = page_title.to_s
    @show_title = show_title
  end
  
  def show_title?
    @show_title
  end
  
  def stylesheet(*args)
    content_for(:stylesheets) { stylesheet_link_tag(*args.map(&:to_s)) }
  end
  
  def javascript(*args)
    args = args.map { |arg| arg == :defaults ? arg : "/plugin_assets/alchemy/javascripts/" + arg.to_s }
    content_for(:javascripts) { javascript_include_tag(*args) }
  end
  
  def merged_javascript(merged_set)
    content_for(:merged_javascripts) { javascript_include_merged(merged_set) }
  end
  
  def new_asset_path_with_session_information(asset_type)
    session_key = ActionController::Base.session_options[:key]
    if asset_type == "picture"
      admin_pictures_path(session_key => cookies[session_key], request_forgery_protection_token => form_authenticity_token)
    elsif asset_type == "attachment"
      admin_attachments_path(session_key => cookies[session_key], request_forgery_protection_token => form_authenticity_token)
    end
  end
  
end
