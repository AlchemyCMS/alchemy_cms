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

NOTE
      todo notice, 'Alchemy v4.0 changes'
    end
  end
end
