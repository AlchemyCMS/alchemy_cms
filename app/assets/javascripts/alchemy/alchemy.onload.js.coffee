$ ->
  # Preloading all background images from CSS files.
  $.preloadCssImages()

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
      Alchemy.pleaseWaitOverlay()
      return

  # Hack for enabling tab focus for <a>'s styled as button.
  $('a.button').attr({tabindex: 0})

  # Locale select handler
  $('select#change_locale').on 'change', (e) ->
    url = Alchemy.current_url
    delimiter = if url.match(/\?/) then '&' else '?'
    window.location = url + delimiter + 'locale=' + $(this).val()
    return

  # Attaches the image loader on all images
  Alchemy.ImageLoader('img')

  return
