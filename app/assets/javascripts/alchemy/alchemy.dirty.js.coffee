window.Alchemy = {} if typeof (window.Alchemy) is "undefined"

$.extend Alchemy,

  ElementDirtyObserver: (selector) ->
    $(selector).find('input[type="text"], select').change (e) =>
      $content = $(e.target)
      $content.addClass('dirty')
      @setElementDirty $content.closest(".element-editor")
      return

  setElementDirty: (element) ->
    $element = $(element)
    $element.addClass('dirty')
    $element
      .find('> .element-header .icon[class*="element_"]')
      .addClass('element_dirty')
    window.onbeforeunload = @pageUnload

  pageUnload: ->
    Alchemy.pleaseWaitOverlay(false)
    Alchemy._t('page_dirty_notice')

  setElementClean: (element) ->
    $element = $(element)
    $element.removeClass('dirty')
    $element.find('> .element-header .icon').removeClass('element_dirty')
    $element.find('> .element-content .dirty').removeClass('dirty')
    window.onbeforeunload = undefined

  isPageDirty: ->
    $('#element_area').find('.element-editor.dirty').length > 0

  isElementDirty: (element) ->
    $(element).hasClass('dirty')

  checkPageDirtyness: (element) ->
    callback = undefined
    if $(element).is("form")
      callback = ->
        $form = $("<form action=\"#{element.action}\" method=\"POST\" style=\"display: none\" />")
        $form.append $(element).find("input")
        $form.appendTo "body"
        $form.submit()
    else if $(element).is("a")
      callback = ->
        window.location.href = element.pathname
    if Alchemy.isPageDirty()
      Alchemy.openConfirmDialog Alchemy._t('page_dirty_notice'),
        title: Alchemy._t('warning')
        ok_label: Alchemy._t('ok')
        cancel_label: Alchemy._t('cancel')
        on_ok: ->
          window.onbeforeunload = undefined
          Alchemy.pleaseWaitOverlay()
          callback()
      false
    else
      true

  PageLeaveObserver: ->
    $('#main_navi a').click (event) ->
      unless Alchemy.checkPageDirtyness(event.currentTarget)
        event.preventDefault()
