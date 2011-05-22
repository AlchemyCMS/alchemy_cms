%w(config essence notice page_layout tableless controller).each do |class_name|
  require File.join(File.dirname(__FILE__), "alchemy", class_name)
end
require 'active_record'
ActiveRecord::Base.class_eval { include Alchemy::Essence }

module Alchemy
  
  def self.version
    version = YAML.load_file(File.join(File.dirname(__FILE__), '..', 'VERSION')).symbolize_keys
    version_number = "#{version[:MAJOR]}.#{version[:MINOR]}.#{version[:PATCH]}"
    version_number += ".#{version[:BUILD]}" unless version[:BUILD].blank?
    version_number
  end
  
  class EssenceError < StandardError;  end
  
end
