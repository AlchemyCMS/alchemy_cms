module Alchemy
  def self.table_name_prefix
    'alchemy_'
  end

  class BaseRecord < ActiveRecord::Base
    self.abstract_class = true

    def active_record_5_1?
      ActiveRecord.gem_version >= Gem::Version.new('5.1.0')
    end
  end
end
