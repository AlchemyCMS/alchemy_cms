module Admin::ElementsHelper

  include ::ElementsHelper

  # Returns an Array for essence_text_editor select options_for_select.
  def elements_by_name_for_select(name, options={})
    defaults = {
      :grouped_by_page => true,
      :from_page => :all
    }
    options = defaults.merge(options)
    elements = all_elements_by_name(
      name,
      :from_page => options[:from_page]
    )
    if options[:grouped_by_page] && options[:from_page] == :all
      elements_for_options = {}
      pages = elements.collect(&:page).compact.uniq
      pages.sort{ |x,y| x.name <=> y.name }.each do |page|
        page_elements = page.elements.select { |e| e.name == name }
        elements_for_options[page.name] = page_elements.map { |pe| [pe.preview_text, pe.id.to_s] }
      end
    else
      elements_for_options = elements.map { |e| [e.preview_text, e.id.to_s] }
      elements_for_options = [''] + elements_for_options
    end
    return elements_for_options
  end

  # Renders the element editor partial
  def render_editor(element)
    render_element(element, :editor)
  end

  # This helper renderes the picture editor for the elements on the Alchemy Desktop.
  # It brings full functionality for adding images to the element, deleting images from it and sorting them via drag'n'drop.
  # Just place this helper inside your element editor view, pass the element as parameter and that's it.
  #
  # Options:
  # :maximum_amount_of_images (integer), default nil. This option let you handle the amount of images your customer can add to this element.
  def render_picture_editor(element, options={})
    default_options = {
      :last_image_deletable => true,
      :maximum_amount_of_images => nil,
      :refresh_sortable => true
    }
    options = default_options.merge(options)
    picture_contents = element.all_contents_by_type("EssencePicture")
    render(
      :partial => "admin/elements/picture_editor",
      :locals => {
        :picture_contents => picture_contents,
        :element => element,
        :options => options
      }
    )
  end

end
