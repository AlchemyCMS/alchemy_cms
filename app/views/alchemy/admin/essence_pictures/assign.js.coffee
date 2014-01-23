$('#picture_to_assign_<%= @picture.id %> a').attr('href', '#').off 'click'
$('#<%= @content.dom_id -%>').replaceWith('<%= escape_javascript(
  render(
    :partial => "alchemy/essences/essence_picture_editor",
    :locals => {:content => @content, :options => @options}
  )
) -%>')

<% if @content.siblings.essence_pictures.count > 1 %>
Alchemy.SortableContents '#<%= @content.element.id -%>_contents', '<%= form_authenticity_token -%>'
<% end %>

Alchemy.closeCurrentDialog()
Alchemy.setElementDirty '#element_<%= @content.element.id -%>'
Alchemy.watchForDialogs '#<%= @content.dom_id %>'
