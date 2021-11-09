module Alchemy::Upgrader::Tasks
  class FixedElementNameFinder

    def call(cell_name)
      return cell_name if fixed_elements.include?(cell_name)
      return "#{cell_name}_elements" if unfixed_elements.include?(cell_name)
      cell_name
    end

    private

    def fixed_elements
      @_fixed_element_names ||= begin
        definitions.select { |element| element['fixed'] }.map { |element| element['name'] }
      end
    end

    def unfixed_elements
      @_unfixed_elements ||= begin
        definitions.reject { |element| element['fixed'] }.map { |element| element['name'] }
      end
    end

    def definitions
      @_definitions ||= begin
        elements_file_path = Rails.root.join('config', 'alchemy', 'elements.yml')
        YAML.load_file(elements_file_path)
      end
    end
  end
end
