class WaAtomMoleculeSelector < ActiveRecord::Base
  belongs_to :wa_molecule
  
  def content
    self.wa_molecule
  end
  
end
