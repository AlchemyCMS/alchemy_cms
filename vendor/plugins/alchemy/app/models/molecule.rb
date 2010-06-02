class Molecule < ActiveRecord::Base
  require 'yaml'

  acts_as_list :scope => :wa_page_id
  stampable :stamper_class_name => :wa_user
  has_many :wa_atoms, :order => :position, :dependent => :destroy
  belongs_to :wa_page
  has_and_belongs_to_many :to_be_sweeped_pages, :class_name => 'WaPage', :uniq => true

  validates_uniqueness_of :position, :scope => :wa_page_id

  before_destroy :remove_atoms

  attr_accessor :create_atoms_after_create
  after_create :create_atoms, :unless => Proc.new { |m| m.create_atoms_after_create == false }
  
  # Returns next Molecule on self.wa_page or nil. Pass a Molecule.name to get next of this kind.
  def next(name = nil)
    if name.nil?
      find_conditions = ["public = 1 AND wa_page_id = ? AND position > ?", self.wa_page.id, self.position]
    else
      find_conditions = ["public = 1 AND wa_page_id = ? AND name = ? AND position > ?", self.wa_page.id, name, self.position]
    end
    self.class.find :first, :conditions => find_conditions, :order => "position ASC"
  end

  # Returns previous Molecule on self.wa_page or nil. Pass a Molecule.name to get previous of this kind.
  def prev(name = nil)
    if name.nil?
      find_conditions = ["public = 1 AND wa_page_id = ? AND position < ?", self.wa_page.id, self.position]
    else
      find_conditions = ["public = 1 AND wa_page_id = ? AND name = ? AND position < ?", self.wa_page.id, name, self.position]
    end
    self.class.find :first, :conditions => find_conditions, :order => "position DESC"
  end

  def store_page page
    unless self.to_be_sweeped_pages.include? page
      self.to_be_sweeped_pages << page
      self.save
    end
  end
  
  def remove_atoms
    self.wa_atoms.each do |atom|
      atom.destroy
    end
  end
  
  def atom_by_name(name)
    self.wa_atoms.find_by_name(name)
  end

  def atom_by_type(atom_type)
    self.wa_atoms.find_by_atom_type(atom_type)
  end

  def all_atoms_by_name(name)
    self.wa_atoms.find_all_by_name(name)
  end

  def all_atoms_by_type(atom_type)
    self.wa_atoms.find_all_by_atom_type(atom_type)
  end
  
  # creates a new molecule for wa_page as described in /config/alchemy/molecules.yml from molecule_name
  def self.create_from_scratch(wa_page_id, molecule_name)
    molecule_scratch = Molecule.descriptions.select{ |m| m["name"] == molecule_name }.first
    raise "Could not find molecule: #{molecule_name}" if molecule_scratch.nil?
    molecule_scratch.delete("wa_atoms")
    molecule_scratch.delete("available_atoms")
    molecule = Molecule.new(
      molecule_scratch.merge({:wa_page_id => wa_page_id})
    )
    molecule.save!
    molecule
  end
  
  # pastes a molecule from the clipboard in the session to wa_page
  def self.paste_from_clipboard(wa_page_id, molecule, method, position)
    copy = self.copy(molecule, :wa_page_id => wa_page_id)
    copy.insert_at(position)
    if method == "move" && copy.valid?
      molecule.destroy
    end
    copy
  end

  def self.descriptions
    if File.exists? "#{RAILS_ROOT}/config/alchemy/molecules.yml"
      @molecules = YAML.load_file( "#{RAILS_ROOT}/config/alchemy/molecules.yml" )
    elsif File.exists? "#{RAILS_ROOT}/vendor/plugins/alchemy/config/alchemy/molecules.yml"
      @molecules = YAML.load_file( "#{RAILS_ROOT}/vendor/plugins/alchemy/config/alchemy/molecules.yml" )
    else
      raise "Could not read config/alchemy/molecules.yml"
    end
  end
  
  # Selects the atom in the molecule.yml description that is flagged as take_me_for_preview or takes the first atom if only one atom exists for molecule.
  # Then selects the atom from the molecule that is equivalent to this flagged atom to display its contect as preview text for molecule editor
  def preview_text
    text = ""
    begin
      my_wa_atoms = my_description["wa_atoms"]
      unless my_wa_atoms.blank?
        atom_flagged_as_preview = my_wa_atoms.select{ |a| a["take_me_for_preview"] }.first
        if atom_flagged_as_preview.blank?
          atom_to_take_as_preview = my_wa_atoms.first
        else
          atom_to_take_as_preview = atom_flagged_as_preview
        end
        preview_atom = self.wa_atoms.select{ |atom| atom.name == atom_to_take_as_preview["name"] }.first
        unless preview_atom.blank?
          if preview_atom.atom_type == "WaAtomRtf"
            text = preview_atom.atom.stripped_content.to_s
          elsif preview_atom.atom_type == "WaAtomText"
            text = preview_atom.atom.content.to_s
          elsif preview_atom.atom_type == "WaAtomPicture"
            text = (preview_atom.atom.wa_image.name rescue "")
          elsif preview_atom.atom_type == "WaAtomFile" || preview_atom.atom_type == "WaAtomFlash" || preview_atom.atom_type == "WaAtomFlashvideo"
            text = (preview_atom.atom.wa_file.name rescue "")
          else
            text = ""
          end
        else
          text = ""
        end
      end
    rescue
      logger.error("#{$!}\n#{$@.join('\n')}")
      text = ""
    end
    text.size > 30 ? text = (text[0..30] + "...") : text
    text
  end
  
  def display_name_with_preview_text
    display_name + ": " + preview_text
  end
  
  def dom_id
    "#{name}_#{id}"
  end
  
  # List all molecules by from page_layout
  def self.list_molecules_by_layout(layout = "standard")
    molecules = Molecule.descriptions
    result = []
    page_layouts = WaPageLayout.get
    layout_molecules = page_layouts.select{|p| p["name"] == layout}.first["molecules"]
    return molecules if layout_molecules == "all"
    molecules.each do |molecule|
      if layout_molecules.include? molecule["name"]
        result << molecule
      end
    end
    return result
  end
  
  def self.get_from_clipboard(clipboard)
    return nil if clipboard.blank?
    self.find(clipboard[:molecule_id])
  end
  
  # returns the collection of available atom_types that can be created for this molecule depending on its description in molecules.yml
  def available_atoms
    my_description['available_atoms']
  end
  
  # returns the description of the molecule with my name in molecule.yml
  def my_description
    Molecule.descriptions.detect{ |d| d["name"] == self.name }
  end
  
private
  
  # List all molecules by from page_layout
  def self.all_for_layout(wa_page, page_layout = "standard")
    molecule_descriptions = Molecule.descriptions
    molecule_names = WaPageLayout.molecule_names_for(page_layout)
    return molecule_descriptions if molecule_names == "all"
    molecules_for_layout = []
    for molecule_description in molecule_descriptions do
      if molecule_names.include?(molecule_description["name"])# TODO: && unique and not already on page
        molecules_for_layout << molecule_description
      end
    end
    
    #TODO: refactor this and place as condition in the above collect
    # all unique molecules from this layout
    unique_molecules = molecules_for_layout.select{ |m| m["unique"] == true }
    molecules_already_on_the_page = wa_page.wa_molecules
    # delete all molecules from the molecules that could be placed that are unique and already and the page
    unique_molecules.each do |unique_molecule|
      molecules_already_on_the_page.each do |already_placed_molecule|
        if already_placed_molecule.name == unique_molecule["name"]
          molecules_for_layout.delete(unique_molecule)
        end
      end
    end
    
    return molecules_for_layout
  end
  
  # makes a copy of source and makes copies of the wa_atoms from source
  def self.copy(source, differences = {})
    differences[:position] = nil
    attributes = source.attributes.except("id").merge(differences)
    wa_molecule = self.create!(attributes.merge(:create_atoms_after_create => false, :id => nil))
    source.wa_atoms.each do |wa_atom|
      new_atom = WaAtom.copy(wa_atom, :wa_molecule_id => wa_molecule.id)
      new_atom.move_to_bottom
    end
    wa_molecule
  end
  
  # creates the atoms for this wa_molecule as described in the molecules.yml
  def create_atoms
    molecule_scratch = my_description
    atoms = []
    if molecule_scratch["wa_atoms"].blank?
      logger.warn "\n++++++\nWARNING! Could not find any atom descriptions for molecule: #{self.name}\n++++++++\n"
    else
      molecule_scratch["wa_atoms"].each do |atom_hash|
        atoms << WaAtom.create_from_scratch(self, atom_hash.symbolize_keys, {:created_from_molecule => true})
      end
    end
  end
  
end
