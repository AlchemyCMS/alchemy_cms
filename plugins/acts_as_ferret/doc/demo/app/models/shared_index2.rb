class SharedIndex2 < ActiveRecord::Base
  acts_as_ferret :index => 'shared'
end
