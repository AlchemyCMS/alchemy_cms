window.Alchemy = {} if typeof(window.Alchemy) is 'undefined'

# The admin sitemap Alchemy module
Alchemy.Sitemap =

  # Storing some objects.
  init: (options) ->
    @search_field = $("#search_field")
    @filter_field_clear = $('.js_filter_field_clear')
    @display = $('#page_filter_result')
    @sitemap_wrapper = $('#sitemap-wrapper')
    @template = Handlebars.compile($('#sitemap-template').html())
    list_template_regexp = new RegExp '\/' + options.page_root_id, 'g'
    list_template_html = $('#sitemap-list').html().replace(list_template_regexp, '/{{id}}')
    @list_template = Handlebars.compile(list_template_html)
    @items = null
    @options = options

    Handlebars.registerPartial('list', list_template_html)

    @fetch()

  # Fetches the sitemap from JSON
  fetch: (foldingId) ->
    self = Alchemy.Sitemap
    spinner_size = @options.spinner_size
    spinner = if spinner_size == 'small' then Alchemy.Spinner.small() else Alchemy.Spinner.medium()

    if foldingId
      spinTarget = $('#fold_button_' + foldingId)
      renderTarget = $('#page_' + foldingId)
      renderTemplate = @list_template
      pageId = foldingId
    else
      spinTarget = @sitemap_wrapper
      renderTarget = @sitemap_wrapper
      renderTemplate = @template
      pageId = @options.page_root_id

    spinner.spin(spinTarget[0])

    request = $.ajax url: @options.url, data:
      id: pageId
      full: @options.full

    request.done (data) ->
      # This will also remove the spinner
      renderTarget.replaceWith(renderTemplate({children: data.pages}))
      self.items = $(".sitemap_page", '#sitemap')
      self._observe()

      Alchemy.watchForDialogs('#sitemap')

      if self.options.ready
        self.options.ready()

    request.fail (jqXHR, status) ->
      Alchemy.debug("Request failed: " + status)

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
