# Initialize all onload scripts at once.
#
# Called at jQuery ready event and Turbo page change event.
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
  $('.please_wait, .button_with_label form :submit')
    .not('*[data-alchemy-confirm]')
    .click Alchemy.pleaseWaitOverlay

  # Hack for enabling tab focus for <a>'s styled as button.
  $('a.button').attr({tabindex: 0})

  # Locale select handler
  $('select#change_locale').on 'change', (e) ->
    url = window.location.pathname
    delimiter = if url.match(/\?/) then '&' else '?'
    Turbo.visit "#{url}#{delimiter}admin_locale=#{$(this).val()}"

  # Site select handler
  $('select#change_site').on 'change', (e) ->
    url = window.location.pathname
    delimiter = if url.match(/\?/) then '&' else '?'
    Turbo.visit "#{url}#{delimiter}site_id=#{$(this).val()}"

  # Submit forms of selects with `data-autosubmit="true"`
  $('select[data-auto-submit="true"]').on 'change', (e) ->
    $(this.form).submit()

  # Attaches the image loader on all images
  Alchemy.ImageLoader('#main_content')

  # Override the filter of keymaster.js so we can blur the fields on esc key.
  key.filter = (event) ->
    tagName = (event.target || event.srcElement).tagName
    key.isPressed('esc') || !(tagName == 'INPUT' || tagName == 'SELECT' || tagName == 'TEXTAREA')

$(document).on 'turbo:load', ->
  Alchemy.Initializer()
  return

$(document).on 'turbo:before-fetch-request', ->
  # Ensure that all tinymce editors get removed before parsing a new page
  Alchemy.Tinymce.removeIntersectionObserver()
  Alchemy.Tinymce.removeFrom $('.has_tinymce')
  return
