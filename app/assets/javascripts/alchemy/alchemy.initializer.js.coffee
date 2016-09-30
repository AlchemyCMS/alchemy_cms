# Initialize all onload scripts at once.
#
# Called at jQuery ready event and Turbolinks page change event.
#
Alchemy.Initializer = ->

  # We obviously have javascript enabled.
  $('html').removeClass('no-js')

  # Add some responsiveness to the menu
  Alchemy.resizeMenu()

  # Initialize the GUI.
  Alchemy.GUI.init()

  # Fade all growl notifications.
  if $('#flash_notices').length > 0
    Alchemy.Growler.fade()

  # Add observer for please wait overlay.
  $('.please_wait, #main_navi a, .button_with_label form :submit, .locked_page a, .pagination a')
    .not('*[data-alchemy-confirm], .locked_page button')
    .click ->
      unless Alchemy.isPageDirty()
        Alchemy.pleaseWaitOverlay()

  # Hack for enabling tab focus for <a>'s styled as button.
  $('a.button').attr({tabindex: 0})

  # Locale select handler
  $('select#change_locale').on 'change', (e) ->
    url = window.location.pathname
    delimiter = if url.match(/\?/) then '&' else '?'
    window.location.href = "#{url}#{delimiter}admin_locale=#{$(this).val()}"

  # Site select handler
  $('select#change_site').on 'change', (e) ->
    url = window.location.pathname
    delimiter = if url.match(/\?/) then '&' else '?'
    window.location.href = "#{url}#{delimiter}site_id=#{$(this).val()}"

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

  # Sticky table headers
  $('table.list').floatThead
    useAbsolutePositioning: false,
    scrollingTop: 122,
    zIndex: 1

  # Focus the search input field if search was clicked
  # Useful for small viewports where the search field is hidden
  $('.search_field, .js_filter_field_box').click ->
    $(this).find('.search_input_field').focus()
    return false

  # For touch based devices we need to trigger the subnavigation on touch
  $('.main_navi_entry.has_sub_navigation').on 'touchstart', '> a', ->
    $subnavigation = $(this).siblings('.sub_navigation')
    $('.sub_navigation').not($subnavigation).removeClass('open').parent().removeClass('hover')
    $subnavigation.toggleClass('open').parent().toggleClass('hover')
    return false

  $('.library_sidebar--toggle').on 'click touchstart', ->
    $('#library_sidebar').toggleClass('open')
    return false

# Enabling the Turbolinks Progress Bar for v2.5
Turbolinks.enableProgressBar() if Turbolinks.enableProgressBar

# Turbolinks DOM Ready.
# Handle both v2.5(page:change), and v.5.0 (turbolinks:load)
$(document).on 'page:change turbolinks:load', ->
  Alchemy.Initializer()
  return

# Turbolinks before parsing a new page
# Handle both v2.5(page:receive), and v.5.0 (turbolinks:request-end)
$(document).on 'page:receive turbolinks:request-end', ->
  # Ensure that all tinymce editors get removed before parsing a new page
  Alchemy.Tinymce.removeFrom $('.has_tinymce')
  return

# Resize the menu if window gets resized
$(window).on('resize', Alchemy.resizeMenu)
