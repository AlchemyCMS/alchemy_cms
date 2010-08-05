class SharedIndex1 < ActiveRecord::Base
  acts_as_ferret :index  => 'shared'
end
