window.Alchemy = {} if typeof(window.Alchemy) is 'undefined'

Alchemy.FixedElements =

  # Inits the fixed elements tabs.
  buildTabs: (label) ->
    $fixed_elements = $('<div id="fixed_elements"/>')
    $('#main_content_elements').wrap($fixed_elements)
    $('#fixed_elements')
      .prepend("<ul><li><a href=\"#main_content_elements\">#{label}</a></li></ul>")
      .tabs 'paging',
        follow: true
        followOnSelect: true
    return

  # Selects tab of given name or creates tab if it's not present yet.
  selectOrCreateTab: (id, label) ->
    $tab = $("#fixed_element_#{id}")
    if $tab.length == 0
      @createTabFor(id, label)
    @_get_container().tabs().tabs('option', 'active', $('#fixed_elements > div').index($tab))
    return

  # Creates fixed element tab for given name.
  createTabFor: (id, label) ->
    $("<li><a href=\"#fixed_element_#{id}\">#{label}</a></li>")
      .appendTo('#fixed_elements .ui-tabs-nav')
    $tab = $("<div id=\"fixed_element_#{id}\" class=\"sortable-elements\"/>")
    @_get_container().append($tab)
    @_get_container().tabs().tabs('refresh')
    return

  # Gets the container div and stores it for later reference
  _get_container: ->
    if @_container?
      @_container
    else
      @_container = $('#fixed_elements')
