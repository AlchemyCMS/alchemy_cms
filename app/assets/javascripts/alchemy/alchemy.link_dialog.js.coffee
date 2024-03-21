# Represents the link Dialog that appears, if a user clicks the link buttons
# in TinyMCE or on an Ingredient that has links enabled (e.g. Picture)
#
class window.Alchemy.LinkDialog extends Alchemy.Dialog

  constructor: (@link_object) ->
    url = new URL(Alchemy.routes.link_admin_pages_path, window.location)
    parameterMapping = {
      url: @link_object.linkUrl,
      selected_tab: @link_object.linkClass,
      link_title: @link_object.linkTitle,
      link_target:@link_object.linkTarget
    }

    # searchParams.set would also add undefined values
    Object.keys(parameterMapping).forEach (key) =>
      url.searchParams.set(key, parameterMapping[key]) if parameterMapping[key]

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
    @linkForm = document.querySelector('[data-link-form-type="internal"]')

    # attach events we handle
    @attachEvents()
    # if we edit an existing link
    if @link_object
      # we select the correct tab
      @selectTab()
    return

  updatePage: (page) ->
    @$internal_link.val(page?.url_path)
    @linkForm.querySelector('alchemy-anchor-select').page = page?.id

  # Attaches click events to forms in the link dialog.
  attachEvents: ->
    # enable the dom selection in internal link tab
    @linkForm.addEventListener "Alchemy.PageSelect.ItemRemoved", (e) => @updatePage()
    @linkForm.addEventListener "Alchemy.PageSelect.ItemAdded", (e) => @updatePage(e.detail)

    $('[data-link-form-type]', @dialog_body).on "submit", (e) =>
      e.preventDefault()
      @link_type = e.target.dataset.linkFormType
      # get url and remove a possible hash fragment
      url = $("##{@link_type}_link").val().replace(/#\w+$/, '')
      if @link_type == 'internal' && @$element_anchor.val() != ''
        url += "#" + @$element_anchor.val()

      # Create the link
      @createLink
        url: url
        title: $("##{@link_type}_link_title").val()
        target: $("##{@link_type}_link_target").val()
      false

  # Creates a link if no validation errors are present.
  # Otherwise shows an error notice.
  createLink: (options) ->
    if @link_type == 'external'
      if options.url.match(Alchemy.link_url_regexp)
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

  # Creates a temporay 'a' element that holds all values on it.
  createTempLink: ->
    tmp_link = document.createElement("a")
    tmp_link.setAttribute('href', @link_object.linkUrl)
    tmp_link.setAttribute('title', @link_object.linkTitle)
    tmp_link.setAttribute('data-link-target', @link_object.linkTarget)
    tmp_link.setAttribute('target', if @link_object.target == 'blank' then '_blank' else "")
    tmp_link.classList.add(@link_object.linkClass) if @link_object.linkClass != ''
    tmp_link

  # Shows validation errors
  showValidationError: ->
    $('#errors ul', @dialog_body).html("<li>#{Alchemy.t('url_validation_failed')}</li>")
    $('#errors', @dialog_body).show()
