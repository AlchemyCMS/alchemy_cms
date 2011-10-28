# Put your plugin routes into here.
Rails.application.routes.draw do
  
  resources :<%= @plugin_name.tableize %>
  
  namespace :admin do
    resources :<%= @plugin_name.tableize %>
  end
  
end
