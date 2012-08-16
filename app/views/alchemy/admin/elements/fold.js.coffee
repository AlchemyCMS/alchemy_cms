<% if @error %>

$("#element_<%= @element.id -%>_folder_spinner").replaceWith("<span class='error_icon' title='<%= @error -%>'>!</span>")

<% else %>

$('#element_<%= @element.id %>').replaceWith('<%= escape_javascript render(:partial => "element", :object => @element) -%>')
$('#element_area .sortable_cell').sortable('refresh')
Alchemy.ElementEditorSelector.reinit('.element_editor[data-element-id="<%= @element.id %>"]')

<% if @element.folded %>

<% @element.rtf_contents.each do |content| %>
rtf_<%= content.id -%> = tinymce.get '<%= content.form_field_id -%>'
rtf_<%= content.id -%>.remove() if rtf_<%= content.id %>
`delete rtf_<%= content.id -%>`
<% end %>

<% else %>
$el = $('#element_<%= @element.id %>')
$el.trigger('Alchemy.SelectElementEditor')
Alchemy.SelectBox($el)

<% @element.rtf_contents.each do |content| %>
Alchemy.Tinymce.addEditor '<%= content.form_field_id -%>'
<% end %>

Alchemy.ElementDirtyObserver $el
Alchemy.Datepicker('input[type="date"]', $el)
Alchemy.ButtonObserver('button.button', $el)
Alchemy.overlayObserver "#element_<%= @element.id -%>"

<% end %>

<% end %>
