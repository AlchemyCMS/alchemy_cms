''
(($, window, document) ->

  if (typeof(Alchemy) is 'undefined')
    window.Alchemy = {}

  LinkOverlay = {}
  $.extend(Alchemy, LinkOverlay)

  Alchemy.LinkOverlay = {

    open:  (linked_element, width) ->
      $dialog = $('<div style="display:none" id="alchemyLinkOverlay"></div>')

      $dialog.html(Alchemy.getOverlaySpinner({x: width}))

      Alchemy.LinkOverlay.current = $dialog.dialog({
        modal: true,
        minWidth: if parseInt(width) < 600 then 600 else parseInt(width),
        minHeight: 450,
        title: 'Link setzen',
        show: "fade",
        hide: "fade",
        resizable: false,
        open: (event, ui) ->
          $.ajax({
            url: Alchemy.routes.link_admin_pages_path,
            success: (data, textStatus, XMLHttpRequest) ->
              $dialog.html(data)
              Alchemy.SelectBox('#alchemyLinkOverlay')
              $dialog.css overflow: 'visible'
              $dialog.dialog('widget').css overflow: 'visible'
              Alchemy.LinkOverlay.attachEvents();
            error: (XMLHttpRequest, textStatus, errorThrown) ->
              Alchemy.AjaxErrorHandler($dialog, XMLHttpRequest.status, textStatus, errorThrown)
          })
        close: ->
          $dialog.remove()
      })
      Alchemy.LinkOverlay.current.linked_element = linked_element

    attachEvents: ->
      self = Alchemy.LinkOverlay
      $('a.sitemap_pagename_link, a.show_elements_to_link', '#alchemyLinkOverlay').on 'click', (e) ->
        e.preventDefault()
        $this = $(this)
        page_id = $this.data('page-id')
        url = $this.data('url')
        self.selectPage(page_id, url)
        self.showElementsSelect(page_id) if $this.hasClass('show_elements_to_link')

    close : ->
      Alchemy.LinkOverlay.current.dialog('close')
      return true

    selectPage : (selected_element, urlname) ->
      $('#page_anchor').removeAttr('value')
      # We have to remove the Attribute. If not the value does not get updated.
      $('.elements_for_page').hide()
      $('#internal_urlname').val('/' + urlname)
      $('#alchemyLinkOverlay #sitemap .selected_page').removeClass('selected_page')
      $('#sitemap_sitename_' + selected_element).addClass('selected_page').attr('name', urlname)

    createLink : (link_type, url, title, target) ->
      element = Alchemy.LinkOverlay.current.linked_element
      Alchemy.setElementDirty($(element).parents('.element_editor'))
      if (element.editor)
        # aka we are linking text inside of TinyMCE
        editor = element.editor
        editor.execCommand('mceInsertLink', false, {
          href: url,
          'class': link_type,
          title: title,
          'data-link-target': target,
          target: if target == 'blank' then '_blank' else null
        })
        editor.selection.collapse()
      else
        # aka: we are linking an essence
        essence_type = element.name.replace('essence_', '').split('_')[0]
        content_id = null
        switch (essence_type)
          when "picture" then content_id = element.name.replace('essence_picture_', '')
          when "text" then content_id = element.name.replace('essence_text_', '')

        $('#contents_content_' + content_id + '_link').val(url).change()
        $('#contents_content_' + content_id + '_link_title').val(title)
        $('#contents_content_' + content_id + '_link_class_name').val(link_type)
        $('#contents_content_' + content_id + '_link_target').val(target)
        $(element).addClass('linked')
        $(element).next().addClass('linked').removeClass('disabled')

    # Selects the tab for kind of link and fills all fields.
    selectTab : ->
      linked_element = Alchemy.LinkOverlay.current.linked_element
      link = '' # initialization really needed?

      # Creating an temporary anchor node if we are linking an EssencePicture or EssenceText.
      if (linked_element.nodeType)
        link = Alchemy.LinkOverlay.createTempLink(linked_element)

      # Restoring the bookmarked selection inside the TinyMCE of an EssenceRichtext.
      else
        if (linked_element.node.nodeName == 'A')
          link = linked_element.node
          linked_element.selection.moveToBookmark(linked_element.bookmark)
        else
          return false

      $('#alchemyLinkOverlay .link_title').val(link.title)
      $('#alchemyLinkOverlay .link_target').val($(link).attr('data-link-target'))

      # Checking of what kind the link is (internal, external, file or contact_form).
      if ($(link).is("a"))
        title = if link.title == null then "" else link.title

        # Handling an internal link.
        if ((link.className == '') || link.className == 'internal')
          internal_anchor = link.hash.split('#')[1]
          internal_urlname = link.pathname
          $('#overlay_tabs').tabs("select", '#overlay_tab_internal_link')
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
              $.get(Alchemy.routes.list_admin_elements_path, {
                page_urlname: $(internal_urlname.split('/')).last()[0],
                internal_anchor: internal_anchor
              })

        # Handling an external link.
        if (link.className == 'external')
          $('#overlay_tabs').tabs("select", '#overlay_tab_external_link')
          $('#external_url').val(link.href)

        # Handling a file link.
        if (link.className == 'file')
          $('#overlay_tabs').tabs("select", '#overlay_tab_file_link')
          $('#public_filename').val(link.pathname + link.search)

        # Handling a contactform link.
        if (link.className == 'contact')
          link_url = link.pathname;
          link_params = link.search;
          link_subject = link_params.split('&')[0];
          link_mailto = link_params.split('&')[1];
          link_body = link_params.split('&')[2];
          $('#overlay_tabs').tabs("select", '#overlay_tab_contactform_link');
          $('#contactform_url').val(link_url);
          $('#contactform_subject').val(unescape(link_subject.replace(/subject=/, '')).replace(/\?/, ''));
          $('#contactform_body').val(unescape(link_body.replace(/body=/, '')).replace(/\?/, ''));
          $('#contactform_mailto').val(link_mailto.replace(/mail_to=/, '').replace(/\?/, ''));

    showElementsSelect: (id) ->
      $('#elements_for_page_' + id).show()
      $('#page_selector_container').scrollTo('#sitemap_sitename_'+id, {duration: 400, offset: -10})

    hideElementsSelect: (id) ->
      $('#elements_for_page_' + id).hide()
      $('#elements_for_page_' + id).html('<img src="/assets/alchemy/ajax_loader.gif" alt="">')
      $('#page_anchor').removeAttr('value')
      $('#page_selector_container').scrollTo('#sitemap_sitename_'+id, {duration: 400, offset: -10})

    createTempLink: (linked_element) ->
      $tmp_link = $("<a></a>")
      essence_type = $(linked_element).attr('name').replace('essence_', '').split('_')[0]
      content_id
      switch (essence_type)
        when "picture" then content_id = $(linked_element).attr('name').replace('essence_picture_', '')
        when "text" then content_id = $(linked_element).attr('name').replace('essence_text_', '')

      $tmp_link.attr('href', $('#contents_content_' + content_id + '_link').val())
      $tmp_link.attr('title', $('#contents_content_' + content_id + '_link_title').val())
      $tmp_link.attr('data-link-target', $('#contents_content_' + content_id + '_link_target').val())
      $tmp_link.attr('target', if $('#contents_content_' + content_id + '_link_target').val() == 'blank' then '_blank' else null)
      $tmp_link.addClass($('#contents_content_' + content_id + '_link_class_name').val())
      return $tmp_link[0]

    removeLink: (link, content_id) ->
      Alchemy.setElementDirty($(link).parents('.element_editor'))
      $('#contents_content_' + content_id + '_link').val('').change()
      $('#contents_content_' + content_id + '_link_title').val('')
      $('#contents_content_' + content_id + '_link_class_name').val('')
      $('#contents_content_' + content_id + '_link_target').val('')
      $(link).removeClass('linked').addClass('disabled')
      $('#edit_link_' + content_id).removeClass('linked')
  }
)(jQuery, window, document)
