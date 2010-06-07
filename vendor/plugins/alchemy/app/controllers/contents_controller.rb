class ContentsController < ApplicationController
  
  layout 'alchemy'
  
  filter_access_to :all
  
  def new
    @element = Element.find(params[:element_id])
    @atoms = @element.available_atoms
    @content = @element.contents.build
    render :layout => false
  end
  
  def create
    begin
      @element = Element.find(params[:content][:element_id])
      @content = Content.create_from_scratch(@element, params[:content])
      @options = params[:options]
      if @content.essence_type == "EssencePicture"
        atoms_of_this_type = @element.contents.find_all_by_essence_type('EssencePicture')
        @dragable = atoms_of_this_type.length > 1
        @options = @options.merge(
          :dragable => @dragable
        )
        unless params[:image_id].blank?
          @content.essence.image_id = params[:image_id]
          @content.essence.save
        end
      end
    rescue Exception => e
      logger.error(e)
      logger.error(e.backtrace.join("\n"))
      render :update do |page|
        WaNotice.show_via_ajax(page, _("atom_not_successfully_added"), :error)
      end
    end
  end
  
  def update
    atom = Content.find(params[:id])
    atom.atom.update_attributes(params[:atom])
    render :update do |page|
      page << "wa_overlay.close();reloadPreview()"
    end
  end
  
  def order
    element = Element.find(params[:element_id])
    for atom_id in params["element_#{element.id}_atoms"]
      content = Content.find(atom_id)
      content.move_to_bottom
    end
    render :update do |page|
      WaNotice.show_via_ajax(page, _("successfully_saved_atom_position"))
      page << "reloadPreview()"
    end
  end
  
  def destroy
    begin
      atom = Content.find(params[:id])
      element = atom.element
      atom_name = atom.name
      content_dom_id = "#{atom.essence_type.underscore}_#{atom.id}"
      if atom.destroy
        render :update do |page|
          page.remove(content_dom_id)
          WaNotice.show_via_ajax(page, _("Successfully deleted %{atom}") % {:atom => atom_name})
          page << "reloadPreview()"
        end
      end
    rescue
      log_error($!)
      render :update do |page|
        WaNotice.show_via_ajax(page, _("atom_not_successfully_deleted"), :error)
      end
    end
  end
  
end
