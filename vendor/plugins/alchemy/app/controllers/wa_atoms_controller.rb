class WaAtomsController < ApplicationController
  
  layout 'washapp'
  
  filter_access_to :all
  
  def new
    @wa_molecule = WaMolecule.find(params[:wa_molecule_id])
    @atoms = @wa_molecule.available_atoms
    @wa_atom = @wa_molecule.wa_atoms.build
    render :layout => false
  end
  
  def create
    begin
      @wa_molecule = WaMolecule.find(params[:wa_atom][:wa_molecule_id])
      @wa_atom = WaAtom.create_from_scratch(@wa_molecule, params[:wa_atom])
      @options = params[:options]
      if @wa_atom.atom_type == "WaAtomPicture"
        atoms_of_this_type = @wa_molecule.wa_atoms.find_all_by_atom_type('WaAtomPicture')
        @dragable = atoms_of_this_type.length > 1
        @options = @options.merge(
          :dragable => @dragable
        )
        unless params[:wa_image_id].blank?
          @wa_atom.atom.wa_image_id = params[:wa_image_id]
          @wa_atom.atom.save
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
    atom = WaAtom.find(params[:id])
    atom.atom.update_attributes(params[:atom])
    render :update do |page|
      page << "wa_overlay.close();reloadPreview()"
    end
  end
  
  def order
    molecule = WaMolecule.find(params[:wa_molecule_id])
    for atom_id in params["molecule_#{molecule.id}_atoms"]
      wa_atom = WaAtom.find(atom_id)
      wa_atom.move_to_bottom
    end
    render :update do |page|
      WaNotice.show_via_ajax(page, _("successfully_saved_atom_position"))
      page << "reloadPreview()"
    end
  end
  
  def destroy
    begin
      atom = WaAtom.find(params[:id])
      wa_molecule = atom.wa_molecule
      atom_name = atom.name
      atom_dom_id = "#{atom.atom_type.underscore}_#{atom.id}"
      if atom.destroy
        render :update do |page|
          page.remove(atom_dom_id)
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
