Alchemy.closeCurrentWindow()

<% if @while_page_edit %>

Alchemy.reloadPreview()
$('#page_<%= @page.id %>_status').replaceWith('<%= escape_javascript(render(:partial => "page_status")) -%>')

<% else %>
$page = $('#page_<%= @page.id %>')
$('.sitemap_page > .sitemap_sitename .sitemap_pagename_link', $page).html('<%= @page.name -%>')

<% if @page.locked? && @page.locker == current_user %>

$('#locked_page_<%= @page.id %> > a').html('<%= @page.name -%>')

<% end %>

$('#page_<%= @page.id %>_infos').html('<%= escape_javascript(render(:partial => "page_infos", :locals => {:page => @page})) -%>')

<% if @page.restricted? %>

$('.page_status:nth-child(3)', $page).addClass('restricted', 'not_restricted').removeClass('not_restricted')

<% elsif @page.redirects_to_external? %>

$('span.redirect_url', $page).html('&raquo; <%= t("Redirects to") %>: <%= h @page.urlname %>')

<% else %>

$('.page_status:nth-child(3)', $page).addClass('not_restricted').removeClass('restricted')

<% end %>

<% end %>

Alchemy.growl("<%= @notice -%>")
