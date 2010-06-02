module ImagesHelper
  
  def create_or_assign_url(image_to_assign, options, swap)
    if @wa_atom.nil?
      {
        :controller => :wa_atoms,
        :action => :create,
        :wa_image_id => image_to_assign.id,
        :wa_atom => {
          :atom_type => "WaAtomPicture",
          :wa_molecule_id => (@wa_molecule.nil? ? nil : @wa_molecule.id)
        },
        :options => options
      }
    else
      {
        :controller => :wa_atom_pictures,
        :action => :assign,
        :wa_image_id => image_to_assign.id,
        :id => @wa_atom.id,
        :options => options,
        :swap => swap
      }
    end
  end
  
end
