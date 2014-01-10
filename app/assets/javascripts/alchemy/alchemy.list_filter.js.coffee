window.Alchemy = {} if typeof(window.Alchemy) is 'undefined'

# The Alchemy list filter
#
# The list items must have a name attribute.
#
# It hides all list items that don't match the term from filter input field.
#
class Alchemy.ListFilterHandler

  # Pass a input field with a data-alchemy-list-filter attribute to this constructor
  constructor: (filter) ->
    @filter_field = $(filter)
    @items = $(@filter_field.data('alchemy-list-filter'))
    @clear = @filter_field.siblings('.js_filter_field_clear')
    @_observe()

  _observe: ->
    @filter_field.on 'keyup', (e) =>
      @clear.show()
      @_filter @filter_field.val()
    @clear.click (e) =>
      e.preventDefault()
      @_clear()
    @filter_field.focus ->
      key.setScope('list_filter')
    key 'esc', 'list_filter', =>
      @_clear()
      @filter_field.blur()

  _filter: (term) ->
    @clear.hide() if term == ''
    @items.map ->
      item = $(this)
      # indexOf is much faster then match()
      if item.attr('name').toLowerCase().indexOf(term.toLowerCase()) != -1
        item.show()
      else
        item.hide()

  _clear: ->
    @filter_field.val ''
    @_filter ''

# Initializes an Alchemy.ListFilterHandler on all input fields with a data-alchemy-list-filter attribute.
#
Alchemy.ListFilter = (scope) ->
  $('[data-alchemy-list-filter]', scope).map ->
    new Alchemy.ListFilterHandler(this)
