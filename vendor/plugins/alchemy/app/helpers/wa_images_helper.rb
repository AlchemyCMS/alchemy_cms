module ImagesHelper
  
  def create_or_assign_url(image_to_assign, options, swap)
    if @atom.nil?
      {
        :controller => :atoms,
        :action => :create,
        :wa_image_id => image_to_assign.id,
        :atom => {
          :atom_type => "Atoms::Picture",
          :molecule_id => (@molecule.nil? ? nil : @molecule.id)
        },
        :options => options
      }
    else
      {
        :controller => :atom_pictures,
        :action => :assign,
        :wa_image_id => image_to_assign.id,
        :id => @atom.id,
        :options => options,
        :swap => swap
      }
    end
  end
  
end
