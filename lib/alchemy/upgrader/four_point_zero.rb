require 'thor'

class Alchemy::Upgrader::FourPointZeroTasks < Thor
  include Thor::Actions

  no_tasks do

    def generate_nestable_elements
      backup_config
      config = read_config

      elements_with_available_contents = config.select { |e| e['available_contents'] }
      elements_with_available_contents.inject(config) do |conf, element|
        build_new_elements(element).inject(conf) do |conf, element_from_contents|
          conf << element_from_contents.deep_dup
        end
      end
      config = config.uniq

      write_config(config)
    end

    def remove_available_contents
      backup_config
      config = read_config

      elements_with_available_contents, new_elements = config.partition { |e| e['available_contents'] }

      print 'Converting to `nestable_elements` ... '
      elements_with_available_contents.inject(new_elements) do |ne, old_element|
        ne << modify_old_element(old_element.dup)
        build_new_elements(old_element).inject(ne) do |ne, element_from_contents|
          ne << element_from_contents
        end
      end
      new_elements = new_elements.uniq.sort {|a, b| a['name'] <=> b['name'] }
      puts 'done.'

      print 'Writing new `config/alchemy/elements.yml` ... '
      write_config(new_elements)
      puts 'done.'

      print 'Removing `render_new_content_link` helper from editor partials ... '
      remove_new_content_link_from_editor_partials
      puts 'done.'

      print 'Adding hints for rendering nested elements to your views ... '
      add_render_nested_elements_hints
      puts 'done.'

      puts "Please run `rails g alchemy:elements --skip` to generate partials for your new nested elements."
    end
  end

  private

  def backup_config
    print "Copying existing config file to config/alchemy/elements.yml.old ... "
    FileUtils.copy  Rails.root.join('config', 'alchemy', 'elements.yml'),
                    Rails.root.join('config', 'alchemy', 'elements.yml.old')
    puts "done."
  end

  def read_config
    print "Reading config/alchemy/elements.yml ... "
    old_config_file = Rails.root.join('config', 'alchemy', 'elements.yml')
    config = YAML.load_file(old_config_file)
    puts "done."
    config
  end

  def write_config(config)
    File.open(Rails.root.join('config', 'alchemy', 'elements.yml'), "w") do |f|
      f.write config.to_yaml
    end
  end

  def modify_old_element(element)
    nestable_elements = element['available_contents'].map do |content|
      "addable_#{content['name']}"
    end
    element.delete('available_contents') # Hashes are mutable. Welcome!
    element['nestable_elements'] = nestable_elements
    element
  end

  def remove_new_content_link_from_editor_partials
    editor_partials = Dir.glob(Rails.root.join('app', 'views', 'alchemy', 'elements', '*_editor*'))
    system "sed -i '' '/^.*render_new_content_link.*$/d' #{editor_partials.join(' ')}"
  end

  def build_new_elements(element)
    element['available_contents'].inject([]) do |collection, content|
      collection << build_new_element(content)
    end
  end

  def build_new_element(content)
    # All nestable elements are deletable
    content['settings'].delete('deletable') if content['settings']
    # If the only content is not present, the whole things doesn't make much sense
    content['validate'] = ['presence']
    content.delete('settings') if content['settings'] == {}
    {
      'name' => "addable_#{content['name']}",
      'contents' => [content]
    }
  end

  def add_render_nested_elements_hints
    erb_views = Dir.glob(Rails.root.join('app', 'views', 'alchemy', 'elements', '*_view.html.erb'))
    haml_slim_views = Dir.glob(Rails.root.join('app', 'views', 'alchemy', 'elements', '*_view.html.haml')) +
                      Dir.glob(Rails.root.join('app', 'views', 'alchemy', 'elements', '*_view.html.slim'))
    erb_snippet = <<ERB
    <!-- Move this up into your element_view_for loop!
    <% element.nested_elements.available.each do |nested_element| %>
      <%= render_element(nested_element) %>
    <% end %>
    -->
ERB
    haml_slim_snippet = <<HAMLSLIM
    - element.nested_elements.available.each do |nested_element|
      = render_element(nested_element)
HAMLSLIM
    erb_views.each { |view| append_to_file view, erb_snippet }
    haml_slim_views.each { |view| append_to_file view, haml_slim_snippet }
  end
end

module Alchemy
  module Upgrader::FourPointZero
    private

    def alchemy_4_0_todos
      notice = <<-NOTE

Element's "available_contents" feature removed
----------------------------------------------

The `available_contents` feature of elements was removed and replaced by nestable elements.

Please update your `config/alchemy/elements.yml` so that you define an element for each content
in `available_contents` and put its name into the `nestable_elements` collection in the parent
element's definition.

## Example:

    - name: link_list
      contents:
      - name: headline
        type: EssenceText
      available_contents:
      - name: link
        type: EssenceText
        settings:
          linkable: true

becomes

    - name: link_list
      contents:
      - name: headline
        type: EssenceText
      nestable_elements:
      - link_list_link

    - name: link_list_link
      contents:
      - name: link
        type: EssenceText
        settings:
          linkable: true

Also update your element view partials, so they use the `element.nested_elements` collection
instead of the `element.contents.named` collection.

## Example:

    element.contents.named(['link', 'attachment']).each do |content|
      render_essence(content)

becomes

    element.nested_elements.published.each do |element|
      render_element(element)

The code for the available contents button in the element editor partial can be removed
without replacement. The nested elements editor partials render automatically.

We have an experimental automatic upgrader which you can call using

    $ rake alchemy:upgrade UPGRADE='generate_nestable_elements'
    $ rake db:migrate
    $ rake alchemy:upgrade UPGRADE='remove_available_contents'

NOTE
      todo notice, 'Alchemy v4.0 changes'
    end

    def generate_nestable_elements
      Alchemy::Upgrader::FourPointZeroTasks.new.generate_nestable_elements
    end

    def remove_available_contents
      Alchemy::Upgrader::FourPointZeroTasks.new.remove_available_contents
    end
  end
end
