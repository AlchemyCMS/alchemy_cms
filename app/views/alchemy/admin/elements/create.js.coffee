<% if @cutted_element_id %>
$('.element_editor[data-element-id="<%= @cutted_element_id %>"]').remove()
<% end %>

<% if @page.can_have_cells? %>
Alchemy.selectOrCreateCellTab('<%= @cell.nil? ? "for_other_elements" : @cell.name -%>', '<%= @cell.nil? ? t("other Elements") : @cell.name_for_label -%>')
<% end %>

$('#cell_<%= @cell.nil? ? "for_other_elements" : @cell.name -%>').append('<%= escape_javascript render(:partial => "element", :object => @element, :locals => {:draggable => true}) -%>')
$('#cell_<%= @cell.nil? ? "for_other_elements" : @cell.name -%>').sortable('refresh')
Alchemy.growl('<%= t("successfully_added_element") -%>')
Alchemy.closeCurrentWindow()

<% @element.rtf_contents.each do |content| %>
Alchemy.Tinymce.addEditor('<%= content.form_field_id -%>')
<% end %>

Alchemy.PreviewWindow.refresh()
Alchemy.ElementEditorSelector.init()

$el = $('#element_<%= @element.id -%>')
$el.trigger('Alchemy.SelectElementEditor')
Alchemy.ElementDirtyObserver($el)
Alchemy.SelectBox('select', $el)
Alchemy.ButtonObserver('button.button', $el)
Alchemy.Datepicker('input[type="date"]', $el)
Alchemy.overlayObserver($el)

<% if @clipboard.blank? %>
$('#clipboard_button .icon.clipboard').removeClass('full')
<% end %>
