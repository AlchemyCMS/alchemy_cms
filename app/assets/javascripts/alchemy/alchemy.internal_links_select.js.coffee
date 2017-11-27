class window.Alchemy.InternalLinksSelect
  constructor: (options) ->
    @$frame = options.frame
    @$selectField = options.selectField
    @$onChange = options.onChange

    @initInternalAnchors()

  # Find Alchemy Elements presents on DOM and populate the select with them
  selectElementsInternalIds: (elements) =>
    if elements.elements.length > 0
      $.each elements.elements, (_, element) =>
        DOMElement = @$frame.contents().find("[data-alchemy-element=\"#{element.id}\"]")
        if DOMElement.size() > 0
          @$selectField.append("<option value='#{DOMElement.attr('id')}'>#{element.display_name_with_preview_text}</option>")
    else
      @$selectField.html("<option>#{Alchemy.t('No anchors found')}</option>")

  #Initialize internal anchors select box
  initInternalAnchors: ->
    pagePathname = @$frame.attr("src").match(/pages\/(\d{1,})\/?/)

    # Extract page number from frame source,
    # get list of alchemy elements from admin api
    # and filter the page elements from the availables alchemy elements
    pageId = pagePathname.slice(-1)[0]
    $.ajax({
      url: "/admin/elements/list.json?page_id=#{pageId}"
    }).done(@selectElementsInternalIds)

    @$selectField.change(@$onChange)

  resetSelectValue: (value)->
    @$selectField.select2('val', value)

