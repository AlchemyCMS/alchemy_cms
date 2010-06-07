class ElementsController < ApplicationController
  
  before_filter :set_translation
  
  @@date_parts = ["%Y", "%m", "%d", "%H", "%M"]
  
  filter_access_to [:show], :attribute_check => true
  filter_access_to [:new, :create, :order, :index], :attribute_check => false
  
  def index
    @page_id = params[:page_id]
    if @page_id.blank? && !params[:page_urlname].blank?
      @page_id = Page.find_by_urlname(params[:page_urlname]).id
    end
    @elements = Element.find_all_by_page_id_and_public(@page_id, true)
  end
  
  def new
    @page = Page.find_by_id(params[:page_id])
    @element_before = Element.find_by_id(params[:element_before_id], :select => :id)
    @elements = Element.all_for_layout(@page, @page.page_layout)
  end
  
  # Creates a element as discribed in config/alchemy/elements.yml on page via AJAX.
  def create
    begin
      if params[:element][:name].blank?
        render :update do |page|
          WaNotice.show_via_ajax(page, _("please_choose_a_element_name"))
        end
      else
        @page = Page.find(params[:page_id])
        unless params[:element_before_id].blank?
          @after_element = Element.find(params[:element_before_id])
        end
        if params[:element][:name] == "paste_from_clipboard"
          element = Element.get_from_clipboard(session[:clipboard])
          @new_element = Element.paste_from_clipboard(
            @page.id,
            element,
            session[:clipboard][:method],
            (@after_element.blank? ? 0 : (@after_element.position + 1))
          )
          if @new_element && session[:clipboard][:method] == 'move'
            session[:clipboard] = nil
          end
        else
          @new_element = Element.create_from_scratch(
            @page.id,
            params[:element][:name]
          )
          unless @after_element.blank?
            @new_element.insert_at(@after_element.position + 1)
          else
            @new_element.insert_at 1
            @page.save
          end
        end
      end
    rescue
      log_error($!)
      render :update do |page|
        WaNotice.show_via_ajax(page, _("adding_element_not_successful"), :error)
      end
    end
  end
  
  def show
    @element = Element.find(params[:id])
    @page = @element.page
    @container_id = params[:container_id]
    render :layout => false
  end
  
  def update
    # TODO: refactor this bastard. i bet to shrink this to 4 rows
    begin
      @element = Element.find_by_id(params[:id])
      #save all contents in this element
      for content in @element.contents
        # this is so god damn ugly. can't wait for rails 2.3 and multiple updates for nested forms
        if content.content_type == "EssenceText"
          # downwards compatibility
          unless params[:contents].blank?
            unless params[:contents]["content_#{content.id}"].blank?
              if params[:contents]["content_#{content.id}"]["content"].nil?
                content.atom.content = params[:contents]["content_#{content.id}"].to_s
              else
                content.atom.content = params[:contents]["content_#{content.id}"]["content"].to_s
              end
            #
            content.atom.link = params[:contents]["content_#{content.id}"]["link"].to_s
            content.atom.title = params[:contents]["content_#{content.id}"]["title"].to_s
            content.atom.link_class_name = params[:contents]["content_#{content.id}"]["link_class_name"].to_s
            content.atom.open_link_in_new_window = params[:contents]["content_#{content.id}"]["open_link_in_new_window"] == 1 ? true : false
            content.atom.public = !params["public"].nil?
            content.atom.save!
            end
          end
        elsif content.content_type == "EssenceRichtext"
          content.atom.content = params[:contents]["content_#{content.id}"]
          content.atom.public = !params["public"].nil?
          content.atom.save!
        elsif content.content_type == "ContentHtml"
          content.atom.content = params[:contents]["content_#{content.id}"]["content"].to_s
          content.atom.save!
        elsif content.content_type == "ContentDate"
          content.atom.date = DateTime.strptime(params[:date].values.join('-'), @@date_parts[0, params[:date].length].join("-"))
          content.atom.save!
        elsif content.content_type == "EssencePicture"
          content.atom.link = params[:contents]["content_#{content.id}"]["link"]
          content.atom.link_title = params[:contents]["content_#{content.id}"]["link_title"]
          content.atom.link_class_name = params[:contents]["content_#{content.id}"]["link_class_name"]
          content.atom.open_link_in_new_window = params[:contents]["content_#{content.id}"]["open_link_in_new_window"]
          content.atom.image_id = params[:contents]["content_#{content.id}"]["image_id"]
          content.atom.caption = params[:images]["caption_#{content.content.id}"] unless params[:images].nil?
          content.atom.save!
        end
      end
      # update the updated_at and updated_by values for the page this element lies on.
      @page = Page.find(@element.page_id)
      @page.update_infos( current_user)
      @element.public = !params[:public].nil?
      @element.save!
      @has_rtf_atoms = @element.contents.detect { |content| content.content_type == 'EssenceRichtext' }
    rescue
      log_error($!)
      render :update do |page|
        WaNotice.show_via_ajax(page, _("element_not_saved"), :error)
      end
    end
  end
  
  # Deletes the element with ajax and sets session[:clipboard].nil
  def destroy
    begin
      @element = Element.find_by_id(params[:id])
      @page = @element.page
      @page.update_infos current_user
      if @element.destroy
        unless session[:clipboard].nil?
          session[:clipboard] = nil if session[:clipboard][:element_id] == params[:id]
        end
      end
    rescue
      log_error($!)
      render :update do |page|
        WaNotice.show_via_ajax(page, _("element_not_successfully_deleted"), :error)
      end
    end
  end
  
  # Copies a element to the clipboard in the session
  def copy_to_clipboard
    begin
      @element = Element.find(params[:id])
      session[:clipboard] = {}
      session[:clipboard][:method] = params[:method]
      session[:clipboard][:element_id] = @element.id
      if session[:clipboard][:method] == "move"
        @element.page_id = nil
        @element.save!
      end
    rescue
      log_error($!)
      render :update do |page|
        WaNotice.show_via_ajax(page, _("element_%{name}_not_moved_to_clipboard") % {:name => @element.display_name}, :error)
      end
    end
  end
  
  def order
    for element in params[:element_area]
      element = Element.find(element)
      element.move_to_bottom
    end
    render :update do |page|
      WaNotice.show_via_ajax(page, _("successfully_saved_element_position"))
      page << "reloadPreview();"
    end
  end
  
  def toggle_fold
    @page = Page.find(params[:page_id], :select => :id)
    @element = Element.find(params[:id])
    @element.folded = !@element.folded
    @element.save!
  rescue => exception
    wa_handle_exception(exception)
    @error = exception
  end
  
end
