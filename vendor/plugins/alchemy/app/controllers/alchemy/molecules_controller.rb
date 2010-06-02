class Alchemy::MoleculesController < ApplicationController
  
  before_filter :set_translation
  
  @@date_parts = ["%Y", "%m", "%d", "%H", "%M"]
  
  filter_access_to [:show], :attribute_check => true
  filter_access_to [:new, :create, :order, :index], :attribute_check => false
  
  def index
    @page_id = params[:page_id]
    if @page_id.blank? && !params[:page_urlname].blank?
      @page_id = Page.find_by_urlname(params[:page_urlname]).id
    end
    @molecules = Molecule.find_all_by_page_id_and_public(@page_id, true)
  end
  
  def new
    @page = Page.find_by_id(params[:page_id])
    @molecule_before = Molecule.find_by_id(params[:molecule_before_id], :select => :id)
    @molecules = Molecule.all_for_layout(@page, @page.page_layout)
  end
  
  # Creates a molecule as discribed in config/alchemy/molecules.yml on page via AJAX.
  def create
    begin
      if params[:molecule][:name].blank?
        render :update do |page|
          Alchemy::Notice.show_via_ajax(page, _("please_choose_a_molecule_name"))
        end
      else
        @page = Page.find(params[:page_id])
        unless params[:molecule_before_id].blank?
          @after_molecule = Molecule.find(params[:molecule_before_id])
        end
        if params[:molecule][:name] == "paste_from_clipboard"
          molecule = Molecule.get_from_clipboard(session[:clipboard])
          @new_molecule = Molecule.paste_from_clipboard(
            @page.id,
            molecule,
            session[:clipboard][:method],
            (@after_molecule.blank? ? 0 : (@after_molecule.position + 1))
          )
          if @new_molecule && session[:clipboard][:method] == 'move'
            session[:clipboard] = nil
          end
        else
          @new_molecule = Molecule.create_from_scratch(
            @page.id,
            params[:molecule][:name]
          )
          unless @after_molecule.blank?
            @new_molecule.insert_at(@after_molecule.position + 1)
          else
            @new_molecule.insert_at 1
            @page.save
          end
        end
      end
    rescue
      log_error($!)
      render :update do |page|
        Alchemy::Notice.show_via_ajax(page, _("adding_element_not_successful"), :error)
      end
    end
  end
  
  def show
    @molecule = Molecule.find(params[:id])
    @page = @molecule.page
    @container_id = params[:container_id]
    render :layout => false
  end
  
  def update
    # TODO: refactor this bastard. i bet to shrink this to 4 rows
    begin
      @molecule = Molecule.find_by_id(params[:id])
      #save all atoms in this molecule
      for atom in @molecule.atoms
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
        elsif atom.atom_type == "Atoms::Picture"
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
      @page = Page.find(@molecule.page_id)
      @page.update_infos( current_user)
      @molecule.public = !params[:public].nil?
      @molecule.save!
      @has_rtf_atoms = @molecule.atoms.detect { |atom| atom.atom_type == 'WaAtomRtf' }
    rescue
      log_error($!)
      render :update do |page|
        Alchemy::Notice.show_via_ajax(page, _("element_not_saved"), :error)
      end
    end
  end
  
  # Deletes the molecule with ajax and sets session[:clipboard].nil
  def destroy
    begin
      @molecule = Molecule.find_by_id(params[:id])
      @page = @molecule.page
      @page.update_infos current_user
      if @molecule.destroy
        unless session[:clipboard].nil?
          session[:clipboard] = nil if session[:clipboard][:molecule_id] == params[:id]
        end
      end
    rescue
      log_error($!)
      render :update do |page|
        Alchemy::Notice.show_via_ajax(page, _("element_not_successfully_deleted"), :error)
      end
    end
  end
  
  # Copies a molecule to the clipboard in the session
  def copy_to_clipboard
    begin
      @molecule = Molecule.find(params[:id])
      session[:clipboard] = {}
      session[:clipboard][:method] = params[:method]
      session[:clipboard][:molecule_id] = @molecule.id
      if session[:clipboard][:method] == "move"
        @molecule.page_id = nil
        @molecule.save!
      end
    rescue
      log_error($!)
      render :update do |page|
        Alchemy::Notice.show_via_ajax(page, _("element_%{name}_not_moved_to_clipboard") % {:name => @molecule.display_name}, :error)
      end
    end
  end
  
  def order
    for molecule in params[:molecule_area]
      molecule = Molecule.find(molecule)
      molecule.move_to_bottom
    end
    render :update do |page|
      Alchemy::Notice.show_via_ajax(page, _("successfully_saved_molecule_position"))
      page << "reloadPreview();"
    end
  end
  
  def toggle_fold
    @page = Page.find(params[:page_id], :select => :id)
    @molecule = Molecule.find(params[:id])
    @molecule.folded = !@molecule.folded
    @molecule.save!
  rescue => exception
    wa_handle_exception(exception)
    @error = exception
  end
  
end
