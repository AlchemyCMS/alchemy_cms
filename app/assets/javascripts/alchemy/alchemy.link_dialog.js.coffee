# Represents the link Dialog that appears, if a user clicks the link buttons
# in TinyMCE or on an Ingredient that has links enabled (e.g. Picture)
#
class window.Alchemy.LinkDialog extends Alchemy.Dialog

  constructor: (@link_object) ->
    url = new URL(Alchemy.routes.link_admin_pages_path, window.location)
    url.searchParams.set("url", @link_object.linkUrl)

    @$link_object = $(@link_object)
    @options =
      size: '600x320'
      title: 'Link'
    super(url.href, @options)

  # Called from Dialog class after the url was loaded
  replace: (data) ->
    # let Dialog class handle the content replacement
    super(data)
    # Store some jQuery objects for further reference
    @$internal_link = $('#internal_link', @dialog_body)
    @$element_anchor = $('#element_anchor', @dialog_body)
    @$anchor_link = $('#anchor_link', @dialog_body)
    @$external_link = $('#external_link', @dialog_body)
    @$file_link = $('#file_link', @dialog_body)
    @$overlay_tabs = $('#overlay_tabs', @dialog_body)
    @$page_container = $('#page_selector_container')

    # attach events we handle
    @attachEvents()
    @initAnchorLinks()
    # if we edit an existing link
    if @link_object
      # we select the correct tab
      @selectTab()
    return

  # Attaches click events to forms in the link dialog.
  attachEvents: ->
    # enable the dom selection in internal link tab
    element_anchor_placeholder = @$element_anchor.attr('placeholder')
    linkForm = document.querySelector('[data-link-form-type="internal"]')
    selectedPageId = linkForm.querySelector('alchemy-page-select').pageId

    if selectedPageId
      @initDomIdSelect(selectedPageId)

    linkForm.addEventListener "Alchemy.PageSelect.ItemRemoved", (e) =>
      @$element_anchor.val(element_anchor_placeholder)
      @$element_anchor.select2('destroy').prop('disabled', true)

    linkForm.addEventListener "Alchemy.PageSelect.ItemAdded", (e) =>
      page = e.detail
      @$element_anchor.val('')
      @$internal_link.val(page.url_path)
      @initDomIdSelect(page.id)

    $('[data-link-form-type]', @dialog_body).on "submit", (e) =>
      e.preventDefault()
      @link_type = e.target.dataset.linkFormType
      url = $("##{@link_type}_link").val()
      if @link_type == 'internal' && @$element_anchor.val() != ''
        url += "##{@$element_anchor.val()}"

      # Create the link
      @createLink
        url: url
        title: $("##{@link_type}_link_title").val()
        target: $("##{@link_type}_link_target").val()
      false

  # Initializes the select2 based dom id select
  # reveals after a page has been selected
  initDomIdSelect: (page_id) ->
    $.get Alchemy.routes.api_ingredients_path, page_id: page_id, (data) =>
      dom_ids = data.ingredients.filter (ingredient) ->
        ingredient.data?.dom_id
      .map (ingredient) ->
        id: ingredient.data.dom_id
        text: "##{ingredient.data.dom_id}"
      @$element_anchor.prop('disabled', false).removeAttr('placeholder').select2
        data: [ id: '', text: Alchemy.t('None') ].concat(dom_ids)

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

  # Sets the link either in TinyMCE or on an Ingredient.
  setLink: (url, title, target) ->
    trimmedUrl = url.trim()
    if @link_object.editor
      @setTinyMCELink(trimmedUrl, title, target)
    else
      @link_object.setLink(trimmedUrl, title, target, @link_type)
    return

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

  # Selects the correct tab for link type and fills all fields.
  selectTab: ->
    # Restoring the bookmarked selection inside the TinyMCE of an Richtext.
    if @link_object.node?.nodeName == 'A'
      @$link = $(@link_object.node)
      @link_object.selection.moveToBookmark(@link_object.bookmark)
    # Creating an temporary anchor node if we are linking an Picture Ingredient.
    else if @link_object.getAttribute && @link_object.getAttribute("is") == "alchemy-link-button"
      @$link = $(@createTempLink())
    else
      return false
    # Populate title and target fields.
    $('.link_title', @dialog_body).val @$link.attr('title')
    $('.link_target', @dialog_body).select2('val', @$link.attr('data-link-target'))
    # Checking of what kind the link is (internal, external or file).
    if @$link.hasClass('external')
      # Handles an external link.
      tab = 'overlay_tab_external_link'
      @$external_link.val(@$link.attr('href'))
    else if @$link.hasClass('file')
      # Handles a file link.
      tab = 'overlay_tab_file_link'
      @$file_link.select2('val', @$link[0].pathname + @$link[0].search)
    else if @$link.attr('href').match(/^#/)
      # Handles an anchor link.
      tab = 'overlay_tab_anchor_link'
      @$anchor_link.select2('val', @$link.attr('href'))
    else if @$link.hasClass('internal')
      # Handles an internal link.
      tab = 'overlay_tab_internal_link'
      @initInternalLinkTab()
    else
      # Emit an event to allow extensions hook into the link overlay.
      @$overlay_tabs.trigger 'SelectLinkTab.Alchemy',
        link: @$link
    if tab
      window.requestAnimationFrame =>
        @$overlay_tabs.get(0).show(tab)
    return

  # Handles actions for internal link tab.
  initInternalLinkTab: ->
    url = @$link.attr('href').split('#')
    # update the url field
    @$internal_link.val(url[0])
    # store the anchor
    @$element_anchor.val(url[1])

  # Creates a temporay 'a' element that holds all values on it.
  createTempLink: ->
    tmp_link = document.createElement("a")
    tmp_link.setAttribute('href', @link_object.linkUrl)
    tmp_link.setAttribute('title', @link_object.linkTitle)
    tmp_link.setAttribute('data-link-target', @link_object.linkTarget)
    tmp_link.setAttribute('target', if @link_object.target == 'blank' then '_blank' else "")
    tmp_link.classList.add(@link_object.linkClass) if @link_object.linkClass != ''
    tmp_link

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
    elements = frame.contentDocument?.querySelectorAll('[id]') || []
    if elements.length > 0
      for element in elements
        @$anchor_link.append("<option value='##{element.id}'>##{element.id}</option>")
    else
      @$anchor_link.html("<option>#{Alchemy.t('No anchors found')}</option>")
    return
