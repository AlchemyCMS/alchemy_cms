require 'alchemy/controller'
require 'alchemy/page_layout'

module Alchemy
  
  def self.version
    version = YAML.load_file(File.join(File.dirname(__FILE__), '..', 'VERSION')).symbolize_keys
    "#{version[:major]}.#{version[:minor]}.#{version[:patch]}"
  end
  
end
