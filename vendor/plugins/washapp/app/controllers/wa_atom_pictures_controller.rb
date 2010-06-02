class WaAtomPicturesController < ApplicationController
  
  layout 'washapp'
  
  filter_access_to :all
  
  def edit
    @wa_atom_picture = WaAtomPicture.find(params[:id])
    @options = params[:options]
    render :layout => false
  end
  
  def update
    @wa_atom_picture = WaAtomPicture.find(params[:id])
    @wa_atom_picture.update_attributes(params[:wa_atom_picture])
    render :update do |page|
      page << "wa_overlay.close(); reloadPreview()"
    end
  end
  
  def assign
    @wa_atom = WaAtom.find_by_id(params[:id])
    @wa_image = WaImage.find_by_id(params[:wa_image_id])
    @wa_atom.atom.wa_image = @wa_image
    @wa_atom.atom.save
    @wa_atom.save
    render :update do |page|
      dom_string = params[:swap] ? "picture" : "assign_atom_#{@wa_atom.wa_molecule.id}"
      page.replace "#{dom_string}_#{@wa_atom.id}", :partial => "wa_atoms/wa_atom_picture_editor", :locals => {:wa_atom => @wa_atom, :options => params[:options]}
      if @wa_atom.wa_molecule.wa_atoms.find_all_by_atom_type("WaAtomPicture").size > 1
        WaConfigure.sortable_atoms(page, @wa_atom.wa_molecule)
      end
      page << "reloadPreview()"
    end
  end
  
  def save_link
    @atom = WaAtom.find(params[:id])
    @picture_atom = @atom.atom
    @picture_atom.link = params[:link]
    @picture_atom.link_title = params[:title]
    @picture_atom.open_link_in_new_window = params[:blank]
    if @picture_atom.save
      render :update do |page|
        page << "Windows.closeAll();reloadPreview()"
        WaNotice.show_via_ajax(page, _("saved_link"))
      end
    end
  end
  
  def destroy
    wa_atom = WaAtom.find_by_id(params[:id])
    wa_molecule = wa_atom.wa_molecule
    wa_molecule.wa_atoms.delete wa_atom
    picture_atoms = wa_molecule.wa_atoms.find_all_by_atom_type("WaAtomPicture")
    render :update do |page|
      page.replace(
        "molecule_#{wa_molecule.id}_atoms",
        :partial => "wa_molecules/wa_picture_editor",
        :locals => {
          :picture_atoms => picture_atoms,
          :wa_molecule => wa_molecule,
          :options => params[:options]
        }
      )
      page << "reloadPreview()"
    end
  end
  
end