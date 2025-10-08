# frozen_string_literal: true

module Alchemy
  module Configurations
    class Importmap < Alchemy::Configuration
      option :importmap_path, :pathname
      option :source_paths, :collection, item_type: :pathname
      option :name, :string
    end
  end
end
