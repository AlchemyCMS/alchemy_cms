# Using Alchemy::Version as the base class for all resources that
# should be versioned avoids conflicts with the host app if its
# using paper_trail as well.
module Alchemy
  class Version < ActiveRecord::Base
    include PaperTrail::VersionConcern
    self.abstract_class = true
  end
end

module Alchemy
  class EssenceVersion < Version
    self.table_name = :alchemy_essence_versions
  end
end

module Alchemy
  class ElementVersion < Version
    self.table_name = :alchemy_element_versions
  end
end
