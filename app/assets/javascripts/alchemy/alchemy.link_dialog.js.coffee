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
    @$page_urlname = $('#page_urlname', @dialog_body)
    @$element_anchor = $('#element_anchor', @dialog_body)
    @$anchor_link = $('#anchor_link', @dialog_body)
    @$external_url = $('#external_url', @dialog_body)
    @$public_filename = $('#public_filename', @dialog_body)
    @$overlay_tabs = $('#overlay_tabs', @dialog_body)
    @$page_container = $('#page_selector_container')
    # if we edit an existing link
    if @link_object
      # we select the correct tab
      @selectTab()
    @initPageSelect()
    @initAnchorLinks()

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
        when 'anchor'
          url = @$anchor_link.val()
        else
          url = @$page_urlname.val()
          if @$element_anchor.val() != ''
            url += "##{@$element_anchor.val()}"
      # Create the link
      @createLink
        url: url
        title: $("##{@link_type}_link_title").val()
        target: $("##{@link_type}_link_target").val()
      false

  # Initializes the select2 based Page select
  initPageSelect: ->
    pageTemplate = HandlebarsTemplates.page
    element_anchor_placeholder = @$element_anchor.attr('placeholder')
    @$page_urlname.select2
      placeholder: Alchemy.t('Search page')
      allowClear: true
      minimumInputLength: 3
      ajax:
        url: Alchemy.routes.api_pages_path
        datatype: 'json'
        quietMillis: 300
        data: (term, page) ->
          q:
            name_cont: term
          page: page
        results: (data) ->
          meta = data.meta
          results:
            data.pages.map (page) ->
              id: page.url_path
              name: page.name
              url_path: page.url_path
              page_id: page.id
          more: meta.page * meta.per_page < meta.total_count
      initSelection: ($element, callback) =>
        urlname = $element.val()
        $.get Alchemy.routes.api_pages_path,
          q:
            urlname_eq: urlname.replace(/^\/([a-z]{2}(-[A-Z]{2})?\/)?/, '')
          page: 1
          per_page: 1,
          (data) =>
            page = data.pages[0]
            if page
              @initElementSelect(page.id)
              callback
                id: page.url_path
                name: page.name
                url_path: page.url_path
                page_id: page.id
      formatSelection: (page) ->
        page.name
      formatResult: (page) ->
        pageTemplate(page: page)
    .on 'change', (event) =>
      if event.val == ''
        @$element_anchor.val(element_anchor_placeholder)
        @$element_anchor.select2('destroy').prop('disabled', true)
      else
        @$element_anchor.val('')
        @initElementSelect(event.added.page_id)

  # Initializes the select2 based elements select
  # reveals after a page has been selected
  initElementSelect: (page_id) ->
    $.get Alchemy.routes.api_elements_path, page_id: page_id, (data) =>
      @$element_anchor.prop('disabled', false).removeAttr('placeholder').select2
        data: [ id: '', text: Alchemy.t('None') ].concat data.elements.map (element) ->
          id: element.dom_id
          text: element.display_name

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
    @$link_object.next().addClass('linked').removeClass('disabled').removeAttr('tabindex')

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
    else if @$link.attr('href').match(/^#/)
      # Handles an anchor link.
      tab = $('#overlay_tab_anchor_link')
      @$anchor_link.select2('val', @$link.attr('href'))
    else
      # Handles an internal link.
      tab = $('#overlay_tab_internal_link')
      @initInternalLinkTab()
    # activate the tab jquery ui 1.10 style o.O
    @$overlay_tabs.tabs('option', 'active', $('#overlay_tabs > div').index(tab))

  # Handles actions for internal link tab.
  initInternalLinkTab: ->
    url = @$link.attr('href').split('#')
    # update the url field
    @$page_urlname.val(url[0])
    # store the anchor
    @$element_anchor.val(url[1])

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
  initAnchorLinks: ->
    frame = document.getElementById('alchemy_preview_window')
    elements = frame.contentDocument.getElementsByTagName('*')
    if elements.length > 0
      for element in elements
        if element.id
          @$anchor_link.append("<option value='##{element.id}'>##{element.id}</option>")
    else
      @$anchor_link.html("<option>#{Alchemy.t('No anchors found')}</option>")
    return

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
      $link.removeClass('linked').addClass('disabled').attr('tabindex', '-1')
      $link.blur()
    $('#edit_link_' + content_id).removeClass('linked')
    false
