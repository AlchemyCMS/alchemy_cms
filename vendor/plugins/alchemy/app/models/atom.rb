class WaAtom < ActiveRecord::Base
  
  belongs_to :atom, :polymorphic => true, :dependent => :destroy
  belongs_to :molecule
  stampable
  acts_as_list
  
  def scope_condition
    "molecule_id = '#{molecule_id}' AND atom_type = '#{atom_type}'"
  end
  
  validates_uniqueness_of :position, :scope => [:molecule_id, :atom_type]
  
  # Creates a new WaAtom as descriped in the molecules.yml file
  def self.create_from_scratch(molecule, atom_hash, options = {})
    options = {:created_from_molecule => false}.merge(options)
    if atom_hash[:name].blank? && !atom_hash[:atom_type].blank?
      atoms_of_same_type = molecule.atoms.find_all_by_atom_type(atom_hash[:atom_type])
      description = {
        'type' => atom_hash[:atom_type],
        'name' => "#{atom_hash[:atom_type].underscore}_#{atoms_of_same_type.length + 1}"
      }
    else
      description = Atom.description_for(
        molecule,
        atom_hash[:name],
        :from_available_atoms => !options[:created_from_molecule]
      )
    end
    raise "No description found in molecules.yml for #{atom_hash.inspect} and #{molecule.inspect}" if description.blank?
    atom_atom_class = ObjectSpace.const_get(description['type'])
    atom = self.new(:name => description['name'], :molecule_id => molecule.id)
    if description['type'] == "WaAtomRtf" || description['type'] == "WaAtomText"
      atom_atom = atom_atom_class.create(:do_not_index => !description['do_not_index'].nil?)
    else
      atom_atom = atom_atom_class.create
    end
    if atom_atom
      atom.atom = atom_atom
      atom.save
    else
      atom = nil
    end
    return atom
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
    atom = self.create!(attributes.except("id"))
    new_atom_atom = atom.atom.clone
    new_atom_atom.save
    atom.atom_id = new_atom_atom.id
    atom
  end
  
  # Returns my description hash from molecules.yml
  def my_description(options={})
    options = {:from_available_atoms => false}.merge(options)
    Atom.description_for(self.molecule, self.name, options)
  end
  
private
  
  # Returns the array with the hashes for all available atoms for molecule in the molecules.yml file
  def self.available_atoms_for(molecule)
    molecule.my_description['available_atoms']
  end
  
  # Returns the array with the hashes for all atoms for molecule in the molecules.yml file
  def self.atoms_for(molecule)
    molecule.my_description['atoms']
  end
  
  # Returns the hash for atom_name in molecule of molecules.yml, either from atoms array, or from available_atoms array.
  # Options: from_available_atoms (default false) detects the hash from the available_atoms array if set to true
  def self.description_for(molecule, atom_name, options={})
    options = {:from_available_atoms => false}.merge(options)
    if options[:from_available_atoms]
      atoms = self.available_atoms_for(molecule)
    else
      atoms = self.atoms_for(molecule)
    end
    atoms.detect{ |d| d['name'] == atom_name } if atoms
  end
  
end
