module Admin::ElementsHelper

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
  
end
