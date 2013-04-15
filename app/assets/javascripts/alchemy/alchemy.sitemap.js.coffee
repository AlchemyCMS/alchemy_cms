window.Alchemy = {} if typeof(window.Alchemy) is 'undefined'

# The admin sitemap Alchemy module
Alchemy.Sitemap =

  # Storing some objects.
  init: ->
    @search_field = $("#search_field")
    @filter_field_clear = $('.js_filter_field_clear')
    @display = $('#page_filter_result')
    @items = $(".sitemap_page", '#sitemap')
    @_observe()

  # Filters the sitemap
  filter: (term) ->
    self = Alchemy.Sitemap
    $results = self.items.filter("[name*='#{term}']")
    length = $results.length
    $results.addClass('highlight').removeClass('no-match')
    self.items.not("[name*='#{term}']").addClass('no-match').removeClass('highlight')
    self.filter_field_clear.show()
    if length == 1
      self.display.show().text("1 #{self._t('page_found')}")
      $.scrollTo($results, {duration: 400, offset: -80})
    else if length > 1
      self.display.show().text("#{length} #{self._t('pages_found')}")
    else
      self.items.removeClass('no-match highlight')
      self.display.hide()
      $.scrollTo('0', 400)
      self.filter_field_clear.hide()

  # Adds onkey up observer to search field
  _observe: ->
    filter = @filter
    @search_field.on 'keyup', ->
      term = $(this).val().toLowerCase()
      filter(term)
    @search_field.on 'focus', ->
      keymage.setScope('search')
    @filter_field_clear.click =>
      @search_field.val('')
      filter('')

  # Translations
  _t: (id) ->
    i18n =
      page_found:
        de: 'Seite gefunden'
        en: 'Page found'
      pages_found:
        de: 'Seiten gefunden'
        en: 'Pages found'
    i18n[id][Alchemy.locale]
