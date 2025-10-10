# frozen_string_literal: true

# Clipboard functionality for Alchemy admin controllers.
module Alchemy::Admin::Clipboard
  extend ActiveSupport::Concern

  included do
    helper_method :clipboard, :clipboard_empty?, :clipboard_items
  end

  # Checks if clipboard for given category is blank
  def clipboard_empty?(category)
    clipboard.blank?
  end

  private

  # Returns clipboard items for given category
  def get_clipboard(category)
    session[:alchemy_clipboard] ||= {}
    session[:alchemy_clipboard][category.to_s] ||= []
  end

  def clipboard_type
    controller_name
  end

  def clipboard
    @clipboard ||= get_clipboard(clipboard_type)
  end

  # Overridden in some controllers which use a different scope/parameters
  def clipboard_items
    @clipboard_items ||= model_class.all_from_clipboard(clipboard)
  end

  def item_from_clipboard
    @item_from_clipboard ||= clipboard.detect { |item| item["id"].to_i == params[:paste_from_clipboard].to_i }
  end

  def paste_from_clipboard
    if params[:paste_from_clipboard]
      source = model_class.find(params[:paste_from_clipboard])
      parent = model_class.find_by(id: resource_params[:parent_id]) if resource_params[:parent_id]
      model_class.copy_and_paste(source, parent, params.dig(clipboard_type.singularize.to_sym, :name))
    end
  end

  def model_class
    "alchemy/#{clipboard_type.singularize}".classify.constantize
  end

  def remove_resource_from_clipboard(resource)
    clipboard = get_clipboard(clipboard_type)
    clipboard.delete_if { |item| item["id"] == resource.id.to_s }
  end
end
