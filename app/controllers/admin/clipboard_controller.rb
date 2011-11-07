class Admin::ClipboardController < AlchemyController

  filter_access_to :all

  before_filter :set_translation

  def index
    clipboard = get_clipboard(params[:remarkable_type].tableize)
    @clipboard_items = params[:remarkable_type].classify.constantize.all_from_clipboard(clipboard)
    respond_to do |format|
      format.html { render :layout => false }
    end
  end

  def insert
    @clipboard = get_clipboard(params[:remarkable_type].tableize)
    @item = params[:remarkable_type].classify.constantize.find(params[:remarkable_id])
    unless @clipboard.collect { |i| i[:id] }.include?(params[:remarkable_id])
      @clipboard.push({:id => params[:remarkable_id], :action => params[:remove] ? 'cut' : 'copy'})
    end
    respond_to do |format|
      format.js
    end
  rescue Exception => e
    exception_handler(e)
  end

  def remove
    @clipboard = get_clipboard(params[:remarkable_type].tableize)
    @item = params[:remarkable_type].classify.constantize.find(params[:remarkable_id])
    @clipboard.delete_if { |i| i[:id] == params[:remarkable_id] }
    respond_to do |format|
      format.js
    end
  rescue Exception => e
    exception_handler(e)
  end

  def clear
    session[:clipboard] = {}
  end

end
