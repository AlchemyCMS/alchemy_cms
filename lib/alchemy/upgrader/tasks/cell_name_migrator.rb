module Alchemy::Upgrader::Tasks
  class CellNameMigrator
    class << self
      def call(cell_name)
        element_name_exists = existing_element_names.find { |name| name == cell_name }
        element_name_exists ? "#{cell_name}_elements" : cell_name
      end

      private

      def existing_element_names
        @_existing_element_names ||= begin
          elements_file_path = Rails.root.join('config', 'alchemy', 'elements.yml')
          YAML.load_file(elements_file_path).map { |element| element['name'] }
        end
      end  
    end
  end
end
