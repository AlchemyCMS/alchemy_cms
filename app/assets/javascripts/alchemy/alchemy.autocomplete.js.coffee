window.Alchemy = {} if typeof(window.Alchemy) is 'undefined'

Alchemy.Autocomplete =

  tags: (scope) ->
    field = $('[data-autocomplete]', scope)
    url = field.data('autocomplete')
    field.select2
      tags: true
      tokenSeparators: [","]
      minimumInputLength: 1
      openOnEnter: false
      createSearchChoice: @_createResultItem
      ajax:
        url: url
        dataType: 'json'
        data: (term, page) -> term: term
        results: (data, page) -> results: data
      initSelection: @_initializeSelection

  _createResultItem: (term, data) ->
    if $(data).filter(-> @text.localeCompare(term) is 0).length is 0
      id: term
      text: term

  _initializeSelection: (element, callback) ->
    data = []
    $(element.val().split(",")).each ->
      data.push id: this, text: this
    callback(data)
