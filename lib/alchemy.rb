require 'alchemy/controller'
require 'alchemy/page_layout'

module Alchemy
  
  def self.version
    version = YAML.load_file(File.join(File.dirname(__FILE__), '..', 'VERSION')).symbolize_keys
    version_number = "#{version[:MAJOR]}.#{version[:MINOR]}.#{version[:PATCH]}"
    version_number += ".#{version[:BUILD]}" unless version[:BUILD].blank?
    version_number
  end
  
  class EssenceError < StandardError;  end
  
end
