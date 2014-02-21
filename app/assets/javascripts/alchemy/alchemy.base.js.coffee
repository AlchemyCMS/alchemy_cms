window.Alchemy = {} if typeof(window.Alchemy) is 'undefined'

# Setting jQueryUIs global animation duration to something more snappy
$.fx.speeds._default = 400

# The Alchemy object contains all base functions, that don't fit in its own module.
# All other modules uses this global Alchemy object as namespace.
$.extend Alchemy,

  # Multiple picture select handler for the picture archive.
  pictureSelector: ->
    $selected_item_tools = $(".selected_item_tools")
    $picture_selects = $(".picture_tool.select input")
    $picture_selects.on "change", ->
      if $picture_selects.filter(":checked").size() > 0
        $selected_item_tools.show()
      else
        $selected_item_tools.hide()
      if @checked
        $(this).parent().addClass("visible").removeClass "hidden"
      else
        $(this).parent().removeClass("visible").addClass "hidden"
      return
    $("a#edit_multiple_pictures").on "click", (e) ->
      $this = $(this)
      picture_ids = $("input:checkbox", "#picture_archive").serialize()
      url = $this.attr("href") + "?" + picture_ids
      Alchemy.openDialog url, {title: $this.attr("title"), size: '400x295'}
      false
    return

  # To show the "Please wait" overlay.
  # Pass false to hide it.
  pleaseWaitOverlay: (show = true) ->
    $overlay = $('#overlay')
    if show
      spinner = Alchemy.Spinner.medium()
      $overlay.append(spinner.spin().el)
      $overlay.show()
    else
      $overlay.find('.spinner').remove()
      $overlay.hide()
    return

  # Shows spinner while loading images and
  # fades the image after its been loaded
  ImageLoader: (scope = document, options = {color: '#fff'}) ->
    $('img', scope).each ->
      image = $(this).hide()
      $parent = image.parent()
      spinner = Alchemy.Spinner.small options
      spinner.spin $parent[0]
      image.on 'load', ->
        spinner.stop()
        image.fadeIn 400
      image.on 'error', ->
        spinner.stop()
        $parent.html('<span class="icon warn"/>')

  removePicture: (selector) ->
    $form_field = $(selector)
    $element = $form_field.parents(".element_editor")
    if $form_field
      $form_field.val ""
      $form_field.prev().remove()
      $form_field.parent().addClass "missing"
      Alchemy.setElementDirty $element
    return

  # Sets the element to saved state
  setElementSaved: (selector) ->
    $element = $(selector)
    Alchemy.setElementClean selector
    Alchemy.Buttons.enable $element
    return true

  # Initializes all select tag with .alchemy_selectbox class as selectBoxIt instance
  # Pass a jQuery scope to only init a subset of selectboxes.
  SelectBox: (scope) ->
    $("select.alchemy_selectbox", scope).select2
      minimumResultsForSearch: 7
      dropdownAutoWidth: true
    return

  Buttons: (options) ->
    $("button, input:submit, a.button").button options
    return

  # Selects cell tab for given name.
  # Creates it if it's not present yet.
  selectOrCreateCellTab: (cell_name, label) ->
    $cells = $('#cells')
    $tab = $("#cell_#{cell_name}")
    if $tab.length == 0
      $("<li><a href=\"#cell_#{cell_name}\">#{label}</a></li>")
        .appendTo('#cells .ui-tabs-nav')
      $tab = $("<div id=\"cell_#{cell_name}\" class=\"sortable_cell\"/>")
      $cells.append($tab)
      $cells.tabs().tabs('refresh')
    $cells.tabs().tabs('option', 'active', $('#cells > div').index($tab))
    return

  # Inits the cell tabs
  buildTabbedCells: (label) ->
    $cells = $('<div id="cells"/>')
    $('#cell_for_other_elements').wrap($cells)
    $('#cells').prepend("<ul><li><a href=\"#cell_for_other_elements\">#{label}</a></li></ul>")
    .tabs 'paging',
      follow: true
      followOnSelect: true
    return

  # Logs exception to js console, if present.
  debug: (e) ->
    if window["console"]
      console.debug e
      console.trace()
    return

  getUrlParam: (name) ->
    results = new RegExp("[\\?&]" + name + "=([^&#]*)").exec(window.location.href)
    results[1] or 0  if results
    return

  isiPhone: navigator.userAgent.match(/iPhone/i) isnt null
  isiPad: navigator.userAgent.match(/iPad/i) isnt null
  isiPod: navigator.userAgent.match(/iPod/i) isnt null
  isiOS: navigator.userAgent.match(/iPad|iPhone|iPod/i) isnt null
  isFirefox: navigator.userAgent.match(/Firefox/i) isnt null
  isChrome: navigator.userAgent.match(/Chrome/i) isnt null
  isSafari: navigator.userAgent.match(/Safari/i) isnt null
  isIE: navigator.userAgent.match(/MSIE/i) isnt null

Alchemy.getBrowserVersion = (browser) ->
  (if Alchemy["is" + browser] then parseInt(navigator.userAgent.match(new RegExp(browser + ".[0-9]+", "i"))[0].replace(new RegExp(browser + "."), ""), 10) else null)
  return

Alchemy.ChromeVersion = Alchemy.getBrowserVersion("Chrome")
Alchemy.FirefoxVersion = Alchemy.getBrowserVersion("Firefox")
Alchemy.SafariVersion = Alchemy.getBrowserVersion("Safari")
Alchemy.IEVersion = Alchemy.getBrowserVersion("MSIE")
