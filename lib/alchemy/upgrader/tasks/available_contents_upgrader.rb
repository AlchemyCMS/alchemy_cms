require 'thor'

module Alchemy::Upgrader::Tasks
  class AvailableContentsUpgrader < Thor
    include Thor::Actions

    AVAILABLE_CONTENTS_REGEXP = /^.*element.contents.(named|where).+\n.*render_essence.+\n(.*end.*\n)?/

    no_tasks do
      def convert_available_contents
        config = read_config
        unless config
          puts "\nNo elements config found. Skipping."
          return
        end

        elements_with_available_contents, new_elements = config.partition do |e|
          e['available_contents']
        end

        if elements_with_available_contents.empty?
          puts "No elements with `available_contents` found. Skipping."
          return
        end

        convert_to_nestable_elements(elements_with_available_contents, new_elements)
        backup_config
        write_config(new_elements)
        remove_new_content_link_from_editor_partials
        replace_available_contents_rendering
        remove_render_available_contents

        puts "Generate new element partials for nestable elements"
        system "rails g alchemy:elements --skip"
      end
    end

    private

    def read_config
      print "1. Reading `config/alchemy/elements.yml` ... "

      old_config_file = Rails.root.join('config', 'alchemy', 'elements.yml')
      config = YAML.load_file(old_config_file)

      if config
        puts "done.\n"
      end

      config
    end

    def convert_to_nestable_elements(elements_with_available_contents, new_elements)
      print '2. Converting to `nestable_elements` ... '

      elements_with_available_contents.inject(new_elements) do |ne, old_element|
        ne << modify_old_element(old_element.dup)
        build_new_elements(old_element).inject(ne) do |e, element_from_contents|
          e << element_from_contents
        end
      end

      puts 'done.'
    end

    def backup_config
      print "3. Copy existing config file to `config/alchemy/elements.yml.old` ... "

      FileUtils.copy Rails.root.join('config', 'alchemy', 'elements.yml'),
                     Rails.root.join('config', 'alchemy', 'elements.yml.old')

      puts "done.\n"
    end

    def write_config(config)
      print '4. Writing new `config/alchemy/elements.yml` ... '

      File.open(Rails.root.join('config', 'alchemy', 'elements.yml'), "w") do |f|
        f.write config.to_yaml
      end

      puts "done.\n"
    end

    def remove_new_content_link_from_editor_partials
      puts '5. Removing available contents link helpers from editor partials ... '

      editor_partials = Dir.glob(Rails.root.join('app', 'views', 'alchemy', 'elements', '*_editor*'))
      editor_partials.each do |partial|
        gsub_file partial,
          /^.*((delete|render_(create|new))_content|label_and_remove)_link.*$\n/, ''
      end
    end

    def replace_available_contents_rendering
      puts '6. Replace available contents rendering with nested elements in your element views:'

      erb_snippet = <<-ERB
    <%- element.nested_elements.available.each do |nested_element| -%>
      <%= render_element(nested_element) %>
    <%- end -%>
ERB
      erb_element_partials(:view).each do |view|
        gsub_file view, AVAILABLE_CONTENTS_REGEXP, erb_snippet
      end

      haml_slim_snippet = <<-HAMLSLIM
    - element.nested_elements.available.each do |nested_element|
      = render_element(nested_element)
HAMLSLIM
      haml_slim_element_partials(:view).each do |view|
        gsub_file view, AVAILABLE_CONTENTS_REGEXP, haml_slim_snippet
      end
    end

    def remove_render_available_contents
      puts '7. Remove available contents rendering from your element editors:'

      erb_element_partials(:editor).each do |view|
        gsub_file view, AVAILABLE_CONTENTS_REGEXP, ''
      end

      haml_slim_element_partials(:editor).each do |view|
        gsub_file view, AVAILABLE_CONTENTS_REGEXP, ''
      end
    end

    def modify_old_element(element)
      nestable_elements = element['available_contents'].map do |content|
        "#{element['name']}_#{content['name']}"
      end
      element.delete('available_contents')
      element['nestable_elements'] = nestable_elements
      element
    end

    def build_new_elements(element)
      element['available_contents'].map do |content|
        build_new_element(element, content)
      end
    end

    def build_new_element(element, content)
      # All nestable elements are deletable
      content['settings'].delete('deletable') if content['settings']
      content.delete('settings') if content['settings'] == {}
      {
        'name' => "#{element['name']}_#{content['name']}",
        'contents' => [content]
      }
    end

    def erb_element_partials(kind)
      Dir.glob(Rails.root.join('app', 'views', 'alchemy', 'elements', "*_#{kind}.html.erb"))
    end

    def haml_slim_element_partials(kind)
      Dir.glob(Rails.root.join('app', 'views', 'alchemy', 'elements', "*_#{kind}.html.{haml,slim}"))
    end
  end
end
