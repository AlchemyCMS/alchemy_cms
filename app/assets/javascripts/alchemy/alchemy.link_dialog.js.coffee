# Represents the link Dialog that appears, if a user clicks the link buttons
# in TinyMCE or on an Essence that has links enabled (e.g. EssencePicture)
#
class window.Alchemy.LinkDialog extends Alchemy.Dialog

  constructor: (@link_object) ->
    @url = Alchemy.routes.link_admin_pages_path
    @$link_object = $(@link_object)
    @options =
      size: '600x320'
      title: 'Link'
    super(@url, @options)

  # Called from Dialog class after the url was loaded
  replace: (data) ->
    # let Dialog class handle the content replacement
    super(data)
    # attach events we handle
    @attachEvents()
    # Store some jQuery objects for further reference
    @$page_anchor = $('#page_anchor', @dialog_body)
    @$internal_urlname = $('#internal_urlname', @dialog_body)
    @$internal_anchor = $('#internal_anchor', @dialog_body)
    @$external_url = $('#external_url', @dialog_body)
    @$public_filename = $('#public_filename', @dialog_body)
    @$overlay_tabs = $('#overlay_tabs', @dialog_body)
    @$page_container = $('#page_selector_container')
    @initInternalAnchors()
    # if we edit an existing link
    if @link_object
      # we select the correct tab
      @selectTab()

  # Attaches click events to several buttons in the link dialog.
  attachEvents: ->
    # The ok buttons
    $('.create-link.button', @dialog_body).click (e) =>
      @link_type = $(e.target).data('link-type')
      switch @link_type
        # get stored url for link type
        when 'external'
          url = @$external_url.val()
        when 'file'
          url = @$public_filename.val()
        else
          url = $("##{@link_type}_urlname").val()
      # Create the link
      @createLink
        url: url
        title: $("##{@link_type}_link_title").val()
        target: $("##{@link_type}_link_target").val()
      false

  # Attaches click events to buttons in the link dialog that appear after the
  # page tree has finished loading.
  attachTreeEvents: ->
    # The select page and show elements links.
    $('a.sitemap_pagename_link, a.show_elements_to_link', @dialog_body).click (e) =>
      $this = $(e.currentTarget)
      page_id = $this.data('page-id')
      url = $this.data('url')
      # Select page in page tree
      @selectPage(page_id)
      # if the show elements link was clicked
      if $this.hasClass('show_elements_to_link')
        # we open the elements select for that page
        @showElementsSelect($this.attr('href'), url)
      else
        # store url
        @$internal_urlname.val('/' + url)
      false
    # Select the current page in the tree
    @selectInternalLinkTab()

  # Sets the page selected and scrolls it in the viewport.
  selectPage: (page_id) ->
    # deselect any selected page from page tree
    @deselectPage()
    # reset the internal anchor select
    @$internal_anchor.select2('val', '')
    $('#sitemap_sitename_' + page_id).addClass('selected_page')
    @$page_container.scrollTo("#sitemap_sitename_#{page_id}", {duration: 400, offset: -10})

  deselectPage: ->
    $('#sitemap .selected_page', @dialog_body).removeClass('selected_page')

  # Creates a link if no validation errors are present.
  # Otherwise shows an error notice.
  createLink: (options) ->
    if @link_type == 'external'
      if @validateURLFormat(options.url)
        @setLink(options.url, options.title, options.target)
      else
        return @showValidationError()
    else
      @setLink(options.url, options.title, options.target)
    @close()

  # Sets the link either in TinyMCE or on an Essence.
  setLink: (url, title, target) ->
    Alchemy.setElementDirty(@$link_object.closest('.element-editor'))
    if @link_object.editor
      @setTinyMCELink(url, title, target)
    else
      @setEssenceLink(url, title, target)

  # Sets a link in TinyMCE editor.
  setTinyMCELink: (url, title, target) ->
    editor = @link_object.editor
    editor.execCommand 'mceInsertLink', false,
      'href': url
      'class': @link_type
      'title': title
      'data-link-target': target
      'target': if target == 'blank' then '_blank' else null
    editor.selection.collapse()
    true

  # Sets a link on an Essence (e.g. EssencePicture).
  setEssenceLink: (url, title, target) ->
    content_id = @$link_object.data('content-id')
    $("#contents_#{content_id}_link").val(url).change()
    $("#contents_#{content_id}_link_title").val(title)
    $("#contents_#{content_id}_link_class_name").val(@link_type)
    $("#contents_#{content_id}_link_target").val(target)
    @$link_object.addClass('linked')
    @$link_object.next().addClass('linked').removeClass('disabled')

  # Selects the correct tab for link type and fills all fields.
  selectTab: ->
    # Creating an temporary anchor node if we are linking an EssencePicture or EssenceText.
    if (@link_object.nodeType)
      @$link = @createTempLink()
    # Restoring the bookmarked selection inside the TinyMCE of an EssenceRichtext.
    else if (@link_object.node.nodeName == 'A')
      @$link = $(@link_object.node)
      @link_object.selection.moveToBookmark(@link_object.bookmark)
    else
      return false
    # Populate title and target fields.
    $('.link_title', @dialog_body).val @$link.attr('title')
    $('.link_target', @dialog_body).select2('val', @$link.attr('data-link-target'))
    # Checking of what kind the link is (internal, external or file).
    if @$link.hasClass('external')
      # Handles an external link.
      tab = $('#overlay_tab_external_link')
      @$external_url.val(@$link.attr('href'))
    else if @$link.hasClass('file')
      # Handles a file link.
      tab = $('#overlay_tab_file_link')
      @$public_filename.select2('val', @$link[0].pathname + @$link[0].search)
    else
      # Handles an internal link.
      tab = $('#overlay_tab_internal_link')
    # activate the tab jquery ui 1.10 style o.O
    @$overlay_tabs.tabs('option', 'active', $('#overlay_tabs > div').index(tab))

  # Handles actions for internal link tab.
  selectInternalLinkTab: ->
    url = @$link.attr('href').split('#')
    urlname = url[0]
    anchor = url[1]
    if anchor
      # store the anchor
      @$page_anchor.val("##{anchor}")
      # and update the url field
      @$internal_urlname.val("#{urlname}##{anchor}")
      # if we linked an internal anchor
      if @$internal_urlname.val().match(/^#/)
        # we select the correct value from anchors select
        value = @$internal_urlname.val()
        @$internal_anchor.select2 'val', value.replace(/^#/, '')
    else
      @$internal_urlname.val(urlname)
    $sitemap_line = $('.sitemap_sitename').closest('[name="'+urlname+'"]')
    if ($sitemap_line.length > 0)
      # Select the line where the link was detected in.
      $sitemap_line.addClass('selected_page')
      @$page_container.scrollTo($sitemap_line.closest('li'), {duration: 400, offset: -10})

  # Opens a new Dialog that shows the elements from given page_id in a selectbox.
  # The value is stored as anchor and the url gets updated so it includes the anchor link
  showElementsSelect: (show_elements_url, urlname) ->
    dialog = new Alchemy.Dialog show_elements_url,
      size: '400x165'
      ready: =>
        $element_select = $('.elements_from_page_selector')
        # check if the urlname is the same as stored,
        current_urlname = @$internal_urlname.val().split('#')[0]
        if "/#{urlname}" == current_urlname
          # then we can select the current anchor in the selectbox
          $element_select.select2 'val', @$page_anchor.val()
        $element_select.change =>
          @$page_anchor.val $element_select.select2('val')
        $('button', dialog.dialog_body).click =>
          @$internal_urlname.val("/#{urlname}#{@$page_anchor.val()}")
          dialog.close()
          false
        return
    dialog.open()
    return

  # Creates a temporay $('a') object that holds all values on it.
  createTempLink: ->
    @$tmp_link = $('<a/>')
    content_id = @$link_object.data('content-id')
    @$tmp_link.attr 'href', $("#contents_#{content_id}_link").val()
    @$tmp_link.attr 'title', $("#contents_#{content_id}_link_title").val()
    @$tmp_link.attr 'data-link-target', $("#contents_#{content_id}_link_target").val()
    @$tmp_link.attr 'target', if $("#contents_#{content_id}_link_target").val() == 'blank' then '_blank' else null
    @$tmp_link.addClass $("#contents_#{content_id}_link_class_name").val()
    @$tmp_link

  # Validates url for beginning with an protocol.
  validateURLFormat: (url) ->
    if url.match(Alchemy.link_url_regexp)
      true
    else
      false

  # Shows validation errors
  showValidationError: ->
    $('#errors ul', @dialog_body).html("<li>#{Alchemy.t('url_validation_failed')}</li>")
    $('#errors', @dialog_body).show()

  # Populates the internal anchors select
  initInternalAnchors: ->
    frame = document.getElementById('alchemy_preview_window')
    elements = frame.contentDocument.getElementsByTagName('*')
    if elements.length > 0
      for element in elements
        if element.id
          @$internal_anchor.append("<option value='#{element.id}'>##{element.id}</option>")
    else
      @$internal_anchor.html("<option>#{Alchemy.t('No anchors found')}</option>")
    @$internal_anchor.change (e) =>
      # deselect any selected page from page tree
      @deselectPage()
      # store the internal anchor as urlname
      $("#internal_urlname").val("##{e.target.value}")

  # Public class methods

  # Removes link from Essence.
  @removeLink = (link, content_id) ->
    $link = $(link)
    $("#contents_#{content_id}_link").val('').change()
    $("#contents_#{content_id}_link_title").val('')
    $("#contents_#{content_id}_link_class_name").val('')
    $("#contents_#{content_id}_link_target").val('')
    if $link.hasClass('linked')
      Alchemy.setElementDirty $(link).closest('.element-editor')
      $link.removeClass('linked').addClass('disabled')
    $('#edit_link_' + content_id).removeClass('linked')
    false
