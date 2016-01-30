window.Alchemy = {} if typeof(window.Alchemy) is 'undefined'

# The admin sitemap Alchemy module
Alchemy.Sitemap =

  # Storing some objects.
  init: (url, page_root_id, sorting) ->
    @search_field = $("#search_field")
    @filter_field_clear = $('.js_filter_field_clear')
    @display = $('#page_filter_result')
    @sitemap_wrapper = $('#sitemap-wrapper')
    @template = Handlebars.compile($('#sitemap-template').html())
    list_template_regexp = new RegExp '\/' + page_root_id, 'g'
    @list_template = $('#sitemap-list').html().replace(list_template_regexp, '/{{id}}')
    @items = null
    @url = url
    @sorting = sorting
    @fetch()

  # Fetches the sitemap from JSON
  fetch: ->
    self = Alchemy.Sitemap
    request = $.ajax @url
    Alchemy.pleaseWaitOverlay()

    request.done (data) ->
      Handlebars.registerPartial('list', self.list_template)
      self.sitemap_wrapper.html(self.template({children: data.pages}))
      self.items = $(".sitemap_page", '#sitemap')
      self._observe()
      Alchemy.PageSorter.init() if self.sorting
      Alchemy.pleaseWaitOverlay(false)

    # TODO: Prettify this.
    request.fail (jqXHR, status) ->
      alert("Request failed: " + status)

  # Filters the sitemap
  filter: (term) ->
    results = []
    self = Alchemy.Sitemap
    self.items.map ->
      item = $(this)
      if term != '' && item.attr('name').toLowerCase().indexOf(term) != -1
        item.addClass('highlight')
        item.removeClass('no-match')
        results.push item
      else
        item.addClass('no-match')
        item.removeClass('highlight')
    self.filter_field_clear.show()
    length = results.length
    if length == 1
      self.display.show().text("1 #{Alchemy._t('page_found')}")
      $.scrollTo(results[0], {duration: 400, offset: -80})
    else if length > 1
      self.display.show().text("#{length} #{Alchemy._t('pages_found')}")
    else
      self.items.removeClass('no-match highlight')
      self.display.hide()
      $.scrollTo('0', 400)
      self.filter_field_clear.hide()

  # Adds onkey up observer to search field
  _observe: ->
    filter = @filter
    @search_field.on 'keyup', ->
      term = $(this).val()
      filter(term.toLowerCase())
    @search_field.on 'focus', ->
      key.setScope('search')
    @filter_field_clear.click =>
      @search_field.val('')
      filter('')
