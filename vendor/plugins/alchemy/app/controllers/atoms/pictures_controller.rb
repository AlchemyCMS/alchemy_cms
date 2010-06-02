class Atoms::PicturesController < ApplicationController
  
  layout 'alchemy'
  
  filter_access_to :all
  
  def edit
    @atom_picture = Atoms::Picture.find(params[:id])
    @options = params[:options]
    render :layout => false
  end
  
  def update
    @atom_picture = Atoms::Picture.find(params[:id])
    @atom_picture.update_attributes(params[:atom_picture])
    render :update do |page|
      page << "wa_overlay.close(); reloadPreview()"
    end
  end
  
  def assign
    @atom = Atom.find_by_id(params[:id])
    @image = Image.find_by_id(params[:wa_image_id])
    @atom.atom.wa_image = @image
    @atom.atom.save
    @atom.save
    render :update do |page|
      dom_string = params[:swap] ? "picture" : "assign_atom_#{@atom.molecule.id}"
      page.replace "#{dom_string}_#{@atom.id}", :partial => "atoms/atom_picture_editor", :locals => {:atom => @atom, :options => params[:options]}
      if @atom.molecule.atoms.find_all_by_atom_type("Atoms::Picture").size > 1
        Alchemy::Configuration.sortable_atoms(page, @atom.molecule)
      end
      page << "reloadPreview()"
    end
  end
  
  def save_link
    @atom = Atom.find(params[:id])
    @picture_atom = @atom.atom
    @picture_atom.link = params[:link]
    @picture_atom.link_title = params[:title]
    @picture_atom.open_link_in_new_window = params[:blank]
    if @picture_atom.save
      render :update do |page|
        page << "Windows.closeAll();reloadPreview()"
        Alchemy::Notice.show_via_ajax(page, _("saved_link"))
      end
    end
  end
  
  def destroy
    atom = Atom.find_by_id(params[:id])
    molecule = atom.molecule
    molecule.atoms.delete atom
    picture_atoms = molecule.atoms.find_all_by_atom_type("Atoms::Picture")
    render :update do |page|
      page.replace(
        "molecule_#{molecule.id}_atoms",
        :partial => "molecules/wa_picture_editor",
        :locals => {
          :picture_atoms => picture_atoms,
          :molecule => molecule,
          :options => params[:options]
        }
      )
      page << "reloadPreview()"
    end
  end
  
end