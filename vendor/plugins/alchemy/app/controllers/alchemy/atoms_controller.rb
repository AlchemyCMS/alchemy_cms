class Alchemy::AtomsController < ApplicationController
  
  layout 'alchemy'
  
  filter_access_to :all
  
  def new
    @molecule = Molecule.find(params[:molecule_id])
    @atoms = @molecule.available_atoms
    @atom = @molecule.atoms.build
    render :layout => false
  end
  
  def create
    begin
      @molecule = Molecule.find(params[:atom][:molecule_id])
      @atom = Atom.create_from_scratch(@molecule, params[:atom])
      @options = params[:options]
      if @atom.atom_type == "Atoms::Picture"
        atoms_of_this_type = @molecule.atoms.find_all_by_atom_type('Atoms::Picture')
        @dragable = atoms_of_this_type.length > 1
        @options = @options.merge(
          :dragable => @dragable
        )
        unless params[:wa_image_id].blank?
          @atom.atom.wa_image_id = params[:wa_image_id]
          @atom.atom.save
        end
      end
    rescue Exception => e
      logger.error(e)
      logger.error(e.backtrace.join("\n"))
      render :update do |page|
        Alchemy::Notice.show_via_ajax(page, _("atom_not_successfully_added"), :error)
      end
    end
  end
  
  def update
    atom = Atom.find(params[:id])
    atom.atom.update_attributes(params[:atom])
    render :update do |page|
      page << "wa_overlay.close();reloadPreview()"
    end
  end
  
  def order
    molecule = Molecule.find(params[:molecule_id])
    for atom_id in params["molecule_#{molecule.id}_atoms"]
      atom = Atom.find(atom_id)
      atom.move_to_bottom
    end
    render :update do |page|
      Alchemy::Notice.show_via_ajax(page, _("successfully_saved_atom_position"))
      page << "reloadPreview()"
    end
  end
  
  def destroy
    begin
      atom = Atom.find(params[:id])
      molecule = atom.molecule
      atom_name = atom.name
      atom_dom_id = "#{atom.atom_type.underscore}_#{atom.id}"
      if atom.destroy
        render :update do |page|
          page.remove(atom_dom_id)
          Alchemy::Notice.show_via_ajax(page, _("Successfully deleted %{atom}") % {:atom => atom_name})
          page << "reloadPreview()"
        end
      end
    rescue
      log_error($!)
      render :update do |page|
        Alchemy::Notice.show_via_ajax(page, _("atom_not_successfully_deleted"), :error)
      end
    end
  end
  
end
