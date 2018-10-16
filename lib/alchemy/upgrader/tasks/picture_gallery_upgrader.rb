require 'thor'
require 'alchemy/upgrader'

module Alchemy::Upgrader::Tasks
  class PictureGalleryUpgrader < Thor
    include Thor::Actions

    GALLERY_PICTURES_ERB_REGEXP = /<%.*element.contents.gallery_pictures.*/
    GALLERY_PICTURES_HAML_REGEXP = /-.*element.contents.gallery_pictures.*/
    GALLERY_PICTURES_EDITOR_REGEXP = /.*render_picture_gallery_editor.*/

    no_tasks do
      def convert_picture_galleries
        config = read_config
        unless config
          puts "\nNo elements config found. Skipping."
          return
        end

        elements_with_picture_gallery, all_other_elements = config.partition do |e|
          e['picture_gallery']
        end

        if elements_with_picture_gallery.empty?
          puts "No elements with `picture_gallery` found. Skipping."
          return
        end

        convert_to_nestable_elements(elements_with_picture_gallery, all_other_elements)
        backup_config
        write_config(all_other_elements)
        find_gallery_pictures_rendering
        remove_gallery_pictures_editor

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

    def convert_to_nestable_elements(elements_with_picture_gallery, all_other_elements)
      print '2. Converting picture gallery elements into `nestable_elements` ... '

      elements_with_picture_gallery.inject(all_other_elements) do |elements, old_element|
        if old_element.fetch('nestable_elements', []).any?
          elements << modify_old_element(old_element.dup, gallery_element: true)
          elements << add_picture_gallery_for(old_element["name"])
          elements << build_new_picture_element_for(old_element["name"], 'picture_gallery')
        else
          elements << modify_old_element(old_element.dup, gallery_element: false)
          elements << build_new_picture_element_for(old_element["name"])
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

    def find_gallery_pictures_rendering
      puts '5. Find element views that use gallery pictures:'

      erb_snippet = <<-ERB
    <%- element.nested_elements.available.each do |nested_element| -%>
      <%= render_element(nested_element) %>
    <%- end -%>
ERB
      erb_views = erb_element_partials(:view).select do |view|
        next if File.read(view).match(GALLERY_PICTURES_ERB_REGEXP).nil?
        inject_into_file view,
          "<%# TODO: Remove next block and render element.nested_elements instead %>\n",
          before: GALLERY_PICTURES_ERB_REGEXP
        true
      end

      haml_slim_snippet = <<-HAMLSLIM
    - element.nested_elements.available.each do |nested_element|
      = render_element(nested_element)
HAMLSLIM
      haml_views = haml_slim_element_partials(:view).select do |view|
        next if File.read(view).match(GALLERY_PICTURES_HAML_REGEXP).nil?
        inject_into_file view,
          "-# TODO: Remove next block and render element.nested_elements instead\n",
          before: GALLERY_PICTURES_HAML_REGEXP
        true
      end

      if erb_views.any?
        puts "- Found #{erb_views.length} ERB element views that render gallery pictures.\n"
        puts "  Please replace `element.contents.gallery_pictures` with:"
        puts erb_snippet
      elsif haml_views.any?
        puts "- Found #{haml_views.length} HAML/SLIM element views render gallery pictures.\n"
        puts "  Please replace `element.contents.gallery_pictures` with:"
        puts haml_slim_snippet
      else
        puts "- No element views found that render gallery pictures.\n"
      end
    end

    def remove_gallery_pictures_editor
      puts '6. Remove gallery pictures editor from your element editors:'

      (erb_element_partials(:editor) + haml_slim_element_partials(:editor)).each do |editor|
        next if File.read(editor).match(GALLERY_PICTURES_EDITOR_REGEXP).nil?
        gsub_file editor, GALLERY_PICTURES_EDITOR_REGEXP, ''
      end
    end

    def modify_old_element(element, gallery_element:)
      if gallery_element
        nestable_element = "#{element['name']}_picture_gallery"
      else
        nestable_element = "#{element['name']}_picture"
      end
      element.delete('picture_gallery')
      element['nestable_elements'] ||= []
      element['nestable_elements'] << nestable_element
      element
    end

    def add_picture_gallery_for(element_name)
      {
        "name" => "#{element_name}_picture_gallery",
        "nestable_elements" => ["#{element_name}_picture_gallery_picture"]
      }
    end

    def build_new_picture_element_for(element_name, gallery_element_name = nil)
      image_options = parse_image_options_from_editor_view(element_name)
      settings = {}
      if image_options[0]
        settings["crop"] = image_options[0] == 'true'
      end
      settings["size"] = image_options[1] if image_options[1]
      element = {
        'name' => [element_name, gallery_element_name, 'picture'].compact.join('_'),
        'compact' => true,
        'contents' => [{
          'name' => 'picture',
          'type' => 'EssencePicture'
        }]
      }
      element['contents'][0]['settings'] = settings if settings.present?
      element
    end

    def parse_image_options_from_editor_view(element_name)
      partial_path = Dir.glob(Rails.root.join('app', 'views', 'alchemy', 'elements', "_#{element_name}_editor.html.*")).first
      partial = File.read(partial_path)
      crop_option = partial.match(/.*render_picture_gallery_editor.*crop(\:|\s?=>)\s?(true|false).*/).try(:[], 2)
      size_option = partial.match(/.*render_picture_gallery_editor.*size(\:|\s?=>)\s?["'](\d*x\d*)["'].*/).try(:[], 2)
      [crop_option, size_option]
    end

    def erb_element_partials(kind)
      Dir.glob(Rails.root.join('app', 'views', 'alchemy', 'elements', "*_#{kind}.html.erb"))
    end

    def haml_slim_element_partials(kind)
      Dir.glob(Rails.root.join('app', 'views', 'alchemy', 'elements', "*_#{kind}.html.{haml,slim}"))
    end
  end
end
