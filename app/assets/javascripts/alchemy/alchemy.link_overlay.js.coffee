Alchemy.LinkOverlay =

  open: (linked_element) ->
    $dialog = $('<div style="display:none" id="alchemyLinkOverlay"></div>')
    $dialog.html(Alchemy.getOverlaySpinner({width: 600, height: 450}))
    @current = $dialog.dialog
      modal: true,
      minWidth: 600,
      minHeight: 450,
      title: 'Link setzen',
      show: "fade",
      hide: "fade",
      resizable: false,
      open: (event, ui) =>
        $.ajax
          url: Alchemy.routes.link_admin_pages_path,
          success: (data, status, xhr) =>
            $dialog.html(data)
            Alchemy.SelectBox('#alchemyLinkOverlay')
            $dialog.css overflow: 'visible'
            $dialog.dialog('widget').css overflow: 'visible'
            @attachEvents()
            $('#overlay_tabs').tabs()
          error: (xhr, status, errorThrown) ->
            Alchemy.AjaxErrorHandler($dialog, xhr.status, status, errorThrown)
      close: ->
        $dialog.remove()
    @current.linked_element = linked_element

  attachEvents: ->
    $('a.sitemap_pagename_link, a.show_elements_to_link', '#alchemyLinkOverlay').click (e) =>
      e.preventDefault()
      $this = $(e.target)
      page_id = $this.data('page-id')
      url = $this.data('url')
      @selectPage(page_id, url)
      if $this.is('.show_elements_to_link')
        Alchemy.Spinner.small().spin($this.next()[0])
      @showElementsSelect(page_id) if $this.hasClass('show_elements_to_link')
    $('.create-link.button', '#alchemyLinkOverlay').click (e) =>
      e.preventDefault()
      link_type = $(e.target).data('link-type')
      if link_type == 'internal'
        url = $('#internal_urlname').val() + $('#page_anchor').val()
      else if link_type == 'external'
        url = $('#external_url').val()
      else if link_type == 'file'
        url = $('#public_filename').val()
      else
        url = $("##{link_type}_urlname").val()
      @createLink link_type,
        url: url,
        title: $("##{link_type}_link_title").val(),
        target: $("##{link_type}_link_target").val()

  close: ->
    @current.dialog('close')
    return true

  selectPage: (selected_element, urlname) ->
    # We have to remove the Attribute. If not the value does not get updated.
    $('#page_anchor').removeAttr('value')
    $('.elements_for_page').hide().html('')
    $('#internal_urlname').val('/' + urlname)
    $('#alchemyLinkOverlay #sitemap .selected_page').removeClass('selected_page')
    $('#sitemap_sitename_' + selected_element).addClass('selected_page').attr('name', urlname)

  createLink: (link_type, options) ->
    if link_type == 'external'
      if @validateURLFormat(options.url)
        @setLink(options.url, link_type, options.title, options.target)
      else
        return @showValidationError()
    else
      @setLink(options.url, link_type, options.title, options.target)
    @close()

  setLink: (url, link_type, title, target) ->
    element = @current.linked_element
    Alchemy.setElementDirty($(element).parents('.element_editor'))
    if (element.editor)
      # aka we are linking text inside of TinyMCE
      @executeTinyMCEcommand(url, title, link_type, target)
    else
      # aka: we are linking an essence
      @linkEssence(url, title, link_type, target)

  # Selects the tab for kind of link and fills all fields.
  selectTab: ->
    linked_element = @current.linked_element
    # Creating an temporary anchor node if we are linking an EssencePicture or EssenceText.
    if (linked_element.nodeType)
      link = @createTempLink(linked_element)
    # Restoring the bookmarked selection inside the TinyMCE of an EssenceRichtext.
    else
      if (linked_element.node.nodeName == 'A')
        link = linked_element.node
        linked_element.selection.moveToBookmark(linked_element.bookmark)
      else
        return false
    $('#alchemyLinkOverlay .link_title').val(link.title)
    $('#alchemyLinkOverlay .link_target').val($(link).attr('data-link-target'))
    # Checking of what kind the link is (internal, external or file).
    if ($(link).is("a"))
      title = if link.title == null then "" else link.title
      # Handling an internal link.
      if ((link.className == '') || link.className == 'internal')
        @selectInternalLinkTab(link)
      # Handling an external link.
      if (link.className == 'external')
        $('#overlay_tabs').tabs().tabs("select", '#overlay_tab_external_link')
        $('#external_url').val(link.href)
      # Handling a file link.
      if (link.className == 'file')
        $('#overlay_tabs').tabs().tabs("select", '#overlay_tab_file_link')
        $('#public_filename').val(link.pathname + link.search)

  selectInternalLinkTab: (link) ->
    internal_anchor = link.hash.split('#')[1]
    internal_urlname = link.pathname
    $('#overlay_tabs').tabs().tabs("select", '#overlay_tab_internal_link')
    $('#internal_urlname').val(internal_urlname)
    $sitemap_line = $('.sitemap_sitename').closest('[name="'+internal_urlname+'"]')
    if ($sitemap_line.length > 0)
      # Select the line where the link was detected in.
      $sitemap_line.addClass("selected_page")
      $('#page_selector_container').scrollTo($sitemap_line.parents('li'), {duration: 400, offset: -10})
      # is there an anchor in the url? then request the element selector via ajax and select the correct value. yeah!
      if (internal_anchor)
        $select_container = $sitemap_line.parent().find('.elements_for_page')
        $select_container.show()
        $.get Alchemy.routes.list_admin_elements_path,
          page_urlname: $(internal_urlname.split('/')).last()[0],
          internal_anchor: internal_anchor

  showElementsSelect: (id) ->
    $('#elements_for_page_' + id).show()
    $('#page_selector_container').scrollTo('#sitemap_sitename_'+id, {duration: 400, offset: -10})

  hideElementsSelect: (id) ->
    $('#elements_for_page_' + id).hide()
    $('#page_anchor').removeAttr('value')
    $('#page_selector_container').scrollTo('#sitemap_sitename_'+id, {duration: 400, offset: -10})

  createTempLink: (linked_element) ->
    $tmp_link = $("<a></a>")
    content_id = $(linked_element).data('content-id')
    $tmp_link.attr('href', $("#contents_#{content_id}_link").val())
    $tmp_link.attr('title', $("#contents_#{content_id}_link_title").val())
    $tmp_link.attr('data-link-target', $("#contents_#{content_id}_link_target").val())
    $tmp_link.attr('target', if $("#contents_#{content_id}_link_target").val() == 'blank' then '_blank' else null)
    $tmp_link.addClass($("#contents_#{content_id}_link_class_name").val())
    return $tmp_link[0]

  removeLink: (link, content_id) ->
    Alchemy.setElementDirty($(link).parents('.element_editor'))
    $("#contents_#{content_id}_link").val('').change()
    $("#contents_#{content_id}_link_title").val('')
    $("#contents_#{content_id}_link_class_name").val('')
    $("#contents_#{content_id}_link_target").val('')
    $(link).removeClass('linked').addClass('disabled')
    $('#edit_link_' + content_id).removeClass('linked')

  executeTinyMCEcommand: (url, title, link_type, target) ->
    element = @current.linked_element
    editor = element.editor
    editor.execCommand('mceInsertLink', false, {
      href: url,
      'class': link_type,
      title: title,
      'data-link-target': target,
      target: if target == 'blank' then '_blank' else null
    })
    editor.selection.collapse()

  linkEssence: (url, title, link_type, target) ->
    element = @current.linked_element
    content_id = $(element).data('content-id')
    $("#contents_#{content_id}_link").val(url).change()
    $("#contents_#{content_id}_link_title").val(title)
    $("#contents_#{content_id}_link_class_name").val(link_type)
    $("#contents_#{content_id}_link_target").val(target)
    $(element).addClass('linked')
    $(element).next().addClass('linked').removeClass('disabled')

  validateURLFormat: (url) ->
    if url.match(/^(mailto:|\/|[a-z]+:\/\/)/)
      return true
    else
      return false

  showValidationError: ->
    $('#errors ul').html("<li>#{Alchemy._t('url_validation_failed')}</li>")
    $('#errors').show()
