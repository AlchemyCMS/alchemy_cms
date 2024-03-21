# Represents the link Dialog that appears, if a user clicks the link buttons
# in TinyMCE or on an Ingredient that has links enabled (e.g. Picture)
#
class window.Alchemy.LinkDialog extends Alchemy.Dialog

  constructor: (link) ->
    url = new URL(Alchemy.routes.link_admin_pages_path, window.location)
    parameterMapping = { url: link.url, selected_tab: link.type, link_title: link.title, link_target: link.target }

    # searchParams.set would also add undefined values
    Object.keys(parameterMapping).forEach (key) =>
      url.searchParams.set(key, parameterMapping[key]) if parameterMapping[key]

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

  # make the open method a promise
  # maybe in a future version the whole Dialog will respond with a promise result if the dialog is closing
  open: () ->
    super
    new Promise (resolve) =>
      @resolve = resolve

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
        @setLink(options)
      else
        return @showValidationError()
    else
      @setLink(options)
    @close()

  # Sets the link either in TinyMCE or on an Ingredient.
  setLink: (options) ->
    trimmedUrl = options.url.trim()
    @resolve({url: trimmedUrl, title: options.title, target: options.target, type: @link_type})

  # Shows validation errors
  showValidationError: ->
    $('#errors ul', @dialog_body).html("<li>#{Alchemy.t('url_validation_failed')}</li>")
    $('#errors', @dialog_body).show()
