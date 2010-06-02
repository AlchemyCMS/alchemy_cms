class WaAtom < ActiveRecord::Base
  
  belongs_to :atom, :polymorphic => true, :dependent => :destroy
  belongs_to :wa_molecule
  stampable :stamper_class_name => :wa_user
  acts_as_list
  
  def scope_condition
    "wa_molecule_id = '#{wa_molecule_id}' AND atom_type = '#{atom_type}'"
  end
  
  validates_uniqueness_of :position, :scope => [:wa_molecule_id, :atom_type]
  
  # Creates a new WaAtom as descriped in the molecules.yml file
  def self.create_from_scratch(wa_molecule, atom_hash, options = {})
    options = {:created_from_molecule => false}.merge(options)
    if atom_hash[:name].blank? && !atom_hash[:atom_type].blank?
      atoms_of_same_type = wa_molecule.wa_atoms.find_all_by_atom_type(atom_hash[:atom_type])
      description = {
        'type' => atom_hash[:atom_type],
        'name' => "#{atom_hash[:atom_type].underscore}_#{atoms_of_same_type.length + 1}"
      }
    else
      description = WaAtom.description_for(
        wa_molecule,
        atom_hash[:name],
        :from_available_atoms => !options[:created_from_molecule]
      )
    end
    raise "No description found in molecules.yml for #{atom_hash.inspect} and #{wa_molecule.inspect}" if description.blank?
    atom_atom_class = ObjectSpace.const_get(description['type'])
    wa_atom = self.new(:name => description['name'], :wa_molecule_id => wa_molecule.id)
    if description['type'] == "WaAtomRtf" || description['type'] == "WaAtomText"
      atom_atom = atom_atom_class.create(:do_not_index => !description['do_not_index'].nil?)
    else
      atom_atom = atom_atom_class.create
    end
    if atom_atom
      wa_atom.atom = atom_atom
      wa_atom.save
    else
      wa_atom = nil
    end
    return wa_atom
  end
  
  # returns the nested atoms content
  def content
    return nil if self.atom.blank?
    self.atom.content
  end
  
  # Settings from the molecules.yml definition
  def settings()
    defaults = {
      :display_as => 'text_field',
      :deletable => false
    }
    description = my_description()
    if description.blank?
      description = my_description(:from_available_atoms => true)
    end
    return {} if description.blank?
    settings = description['settings']
    return defaults if settings.blank?
    settings.merge(defaults).symbolize_keys!
  end
  
  # makes a copy of source and copies the polymorphic associated atom
  def self.copy(source, differences = {})
    differences[:position] = nil
    differences[:id] = nil
    attributes = source.attributes.merge(differences)
    wa_atom = self.create!(attributes.except("id"))
    new_atom_atom = wa_atom.atom.clone
    new_atom_atom.save
    wa_atom.atom_id = new_atom_atom.id
    wa_atom
  end
  
  # Returns my description hash from molecules.yml
  def my_description(options={})
    options = {:from_available_atoms => false}.merge(options)
    WaAtom.description_for(self.wa_molecule, self.name, options)
  end
  
private
  
  # Returns the array with the hashes for all available wa_atoms for wa_molecule in the molecules.yml file
  def self.available_atoms_for(wa_molecule)
    wa_molecule.my_description['available_atoms']
  end
  
  # Returns the array with the hashes for all wa_atoms for wa_molecule in the molecules.yml file
  def self.wa_atoms_for(wa_molecule)
    wa_molecule.my_description['wa_atoms']
  end
  
  # Returns the hash for atom_name in wa_molecule of molecules.yml, either from wa_atoms array, or from available_atoms array.
  # Options: from_available_atoms (default false) detects the hash from the available_atoms array if set to true
  def self.description_for(wa_molecule, atom_name, options={})
    options = {:from_available_atoms => false}.merge(options)
    if options[:from_available_atoms]
      atoms = self.available_atoms_for(wa_molecule)
    else
      atoms = self.wa_atoms_for(wa_molecule)
    end
    atoms.detect{ |d| d['name'] == atom_name } if atoms
  end
  
end
