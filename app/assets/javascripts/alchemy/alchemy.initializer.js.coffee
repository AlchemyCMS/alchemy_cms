# Initialize all onload scripts at once.
#
# Called at jQuery ready event and Turbolinks page change event.
#
Alchemy.Initializer = ->

  # We obviously have javascript enabled.
  $('html').removeClass('no-js')

  # Initialize the GUI.
  Alchemy.GUI.init()

  # Fade all growl notifications.
  if $('#flash_notices').length > 0
    Alchemy.Growler.fade()

  # Add observer for please wait overlay.
  $('a.please_wait, #main_navi a.main_navi_entry, div.button_with_label form :submit, #sub_navigation .subnavi_tab a, .pagination a')
    .not('*[data-alchemy-confirm], #subnav_additions .subnavi_tab button')
    .click ->
      unless Alchemy.isPageDirty()
        Alchemy.pleaseWaitOverlay()

  # Hack for enabling tab focus for <a>'s styled as button.
  $('a.button').attr({tabindex: 0})

  # Locale select handler
  $('select#change_locale').on 'change', (e) ->
    url = window.location.pathname
    delimiter = if url.match(/\?/) then '&' else '?'
    window.location.href = "#{url}#{delimiter}locale=#{$(this).val()}"

  # Submit forms of selects with `data-autosubmit="true"`
  $('select[data-auto-submit="true"]').on 'change', (e) ->
    Alchemy.pleaseWaitOverlay()
    $(this.form).submit()

  # Attaches the image loader on all images
  Alchemy.ImageLoader('#main_content')

  # Override the filter of keymaster.js so we can blur the fields on esc key.
  key.filter = (event) ->
    tagName = (event.target || event.srcElement).tagName
    key.isPressed('esc') || !(tagName == 'INPUT' || tagName == 'SELECT' || tagName == 'TEXTAREA')

# Turbolinks DOM Ready
$(document).on 'page:change', ->
  Alchemy.Initializer()
