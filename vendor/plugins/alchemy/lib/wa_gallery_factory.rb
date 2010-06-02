module WaGalleryFactory
  def create_gallery index_page, molecule
    i = index_page.children.size + 1
    #new gallery page with gallery molecule on it
    new_page = WaPage.create(:name => "Gallerie #{i}", :urlname  => "#{index_page.name}_#{i}", :public => false)
    new_page.update_infos current_user
    new_page.save!
    new_page.move_to_child_of index_page
    get_molecule_factory.create_molecule("picture_gallery", new_page, "0")
    
    #tell the gallery atom the page it belongs to
    for atom in molecule.wa_atoms
      atom.atom.wa_page = new_page if atom.atom_type == "WaAtomGallery"
      atom.atom.save
    end
  end
end