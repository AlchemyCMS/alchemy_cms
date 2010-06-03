class WaMoleculesController < ApplicationController
  
  before_filter :set_translation
  
  @@date_parts = ["%Y", "%m", "%d", "%H", "%M"]
  
  filter_access_to [:show], :attribute_check => true
  filter_access_to [:new, :create, :order, :index], :attribute_check => false
  
  def index
    @wa_page_id = params[:wa_page_id]
    if @wa_page_id.blank? && !params[:wa_page_urlname].blank?
      @wa_page_id = WaPage.find_by_urlname(params[:wa_page_urlname]).id
    end
    @wa_molecules = WaMolecule.find_all_by_wa_page_id_and_public(@wa_page_id, true)
  end
  
  def new
    @wa_page = WaPage.find_by_id(params[:page_id])
    @molecule_before = WaMolecule.find_by_id(params[:molecule_before_id], :select => :id)
    @molecules = WaMolecule.all_for_layout(@wa_page, @wa_page.page_layout)
  end
  
  # Creates a molecule as discribed in config/alchemy/molecules.yml on wa_page via AJAX.
  def create
    begin
      if params[:wa_molecule][:name].blank?
        render :update do |page|
          WaNotice.show_via_ajax(page, _("please_choose_a_molecule_name"))
        end
      else
        @wa_page = WaPage.find(params[:wa_page_id])
        unless params[:molecule_before_id].blank?
          @after_molecule = WaMolecule.find(params[:molecule_before_id])
        end
        if params[:wa_molecule][:name] == "paste_from_clipboard"
          molecule = WaMolecule.get_from_clipboard(session[:clipboard])
          @new_molecule = WaMolecule.paste_from_clipboard(
            @wa_page.id,
            molecule,
            session[:clipboard][:method],
            (@after_molecule.blank? ? 0 : (@after_molecule.position + 1))
          )
          if @new_molecule && session[:clipboard][:method] == 'move'
            session[:clipboard] = nil
          end
        else
          @new_molecule = WaMolecule.create_from_scratch(
            @wa_page.id,
            params[:wa_molecule][:name]
          )
          unless @after_molecule.blank?
            @new_molecule.insert_at(@after_molecule.position + 1)
          else
            @new_molecule.insert_at 1
            @wa_page.save
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
    @wa_molecule = WaMolecule.find(params[:id])
    @wa_page = @wa_molecule.wa_page
    @container_id = params[:container_id]
    render :layout => false
  end
  
  def update
    # TODO: refactor this bastard. i bet to shrink this to 4 rows
    begin
      @molecule = WaMolecule.find_by_id(params[:id])
      #save all atoms in this molecule
      for atom in @molecule.wa_atoms
        # this is so god damn ugly. can't wait for rails 2.3 and multiple updates for nested forms
        if atom.atom_type == "WaAtomText"
          # downwards compatibility
          unless params[:atoms].blank?
            unless params[:atoms]["atom_#{atom.id}"].blank?
              if params[:atoms]["atom_#{atom.id}"]["content"].nil?
                atom.atom.content = params[:atoms]["atom_#{atom.id}"].to_s
              else
                atom.atom.content = params[:atoms]["atom_#{atom.id}"]["content"].to_s
              end
            #
            atom.atom.link = params[:atoms]["atom_#{atom.id}"]["link"].to_s
            atom.atom.title = params[:atoms]["atom_#{atom.id}"]["title"].to_s
            atom.atom.link_class_name = params[:atoms]["atom_#{atom.id}"]["link_class_name"].to_s
            atom.atom.open_link_in_new_window = params[:atoms]["atom_#{atom.id}"]["open_link_in_new_window"] == 1 ? true : false
            atom.atom.public = !params["public"].nil?
            atom.atom.save!
            end
          end
        elsif atom.atom_type == "WaAtomRtf"
          atom.atom.content = params[:atoms]["atom_#{atom.id}"]
          atom.atom.public = !params["public"].nil?
          atom.atom.save!
        elsif atom.atom_type == "WaAtomHtml"
          atom.atom.content = params[:atoms]["atom_#{atom.id}"]["content"].to_s
          atom.atom.save!
        elsif atom.atom_type == "WaAtomTeaserLink"
          atom.atom.text = params[:atoms]["atom_#{atom.id}"]
          atom.atom.save!
        elsif atom.atom_type == "WaAtomDate"
          atom.atom.date = DateTime.strptime(params[:date].values.join('-'), @@date_parts[0, params[:date].length].join("-"))
          atom.atom.save!
        elsif atom.atom_type == "WaAtomPicture"
          atom.atom.link = params[:atoms]["atom_#{atom.id}"]["link"]
          atom.atom.link_title = params[:atoms]["atom_#{atom.id}"]["link_title"]
          atom.atom.link_class_name = params[:atoms]["atom_#{atom.id}"]["link_class_name"]
          atom.atom.open_link_in_new_window = params[:atoms]["atom_#{atom.id}"]["open_link_in_new_window"]
          atom.atom.wa_image_id = params[:atoms]["atom_#{atom.id}"]["wa_image_id"]
          atom.atom.caption = params[:images]["caption_#{atom.atom.id}"] unless params[:images].nil?
          atom.atom.save!
        elsif(
            atom.atom_type == "WaAtomTextfield" || 
            atom.atom_type == "WaAtomTextarea" || 
            atom.atom_type == "WaAtomSelectbox" || 
            atom.atom_type == "WaAtomCheckbox" || 
            atom.atom_type == "WaAtomSubmitbutton" || 
            atom.atom_type == "WaAtomResetbutton" || 
            atom.atom_type == "WaAtomFormtag"
          )
          unless params[:atoms].nil?
            atom.atom.update_attributes!(params[:atoms]["atom_#{atom.id}"])
          end
        end
      end
      # update the updated_at and updated_by values for the page this molecule lies on.
      @wa_page = WaPage.find(@molecule.wa_page_id)
      @wa_page.update_infos( current_user)
      @molecule.public = !params[:public].nil?
      @molecule.save!
      @has_rtf_atoms = @molecule.wa_atoms.detect { |atom| atom.atom_type == 'WaAtomRtf' }
    rescue
      log_error($!)
      render :update do |page|
        WaNotice.show_via_ajax(page, _("element_not_saved"), :error)
      end
    end
  end
  
  # Deletes the molecule with ajax and sets session[:clipboard].nil
  def destroy
    begin
      @molecule = WaMolecule.find_by_id(params[:id])
      @wa_page = @molecule.wa_page
      @wa_page.update_infos current_user
      if @molecule.destroy
        unless session[:clipboard].nil?
          session[:clipboard] = nil if session[:clipboard][:molecule_id] == params[:id]
        end
      end
    rescue
      log_error($!)
      render :update do |page|
        WaNotice.show_via_ajax(page, _("element_not_successfully_deleted"), :error)
      end
    end
  end
  
  # Copies a molecule to the clipboard in the session
  def copy_to_clipboard
    begin
      @molecule = WaMolecule.find(params[:id])
      session[:clipboard] = {}
      session[:clipboard][:method] = params[:method]
      session[:clipboard][:molecule_id] = @molecule.id
      if session[:clipboard][:method] == "move"
        @molecule.wa_page_id = nil
        @molecule.save!
      end
    rescue
      log_error($!)
      render :update do |page|
        WaNotice.show_via_ajax(page, _("element_%{name}_not_moved_to_clipboard") % {:name => @molecule.display_name}, :error)
      end
    end
  end
  
  def order
    for molecule in params[:wa_molecule_area]
      molecule = WaMolecule.find(molecule)
      molecule.move_to_bottom
    end
    render :update do |page|
      WaNotice.show_via_ajax(page, _("successfully_saved_molecule_position"))
      page << "reloadPreview();"
    end
  end
  
  def toggle_fold
    @wa_page = WaPage.find(params[:wa_page_id], :select => :id)
    @wa_molecule = WaMolecule.find(params[:id])
    @wa_molecule.folded = !@wa_molecule.folded
    @wa_molecule.save!
  rescue => exception
    wa_handle_exception(exception)
    @error = exception
  end
  
end
