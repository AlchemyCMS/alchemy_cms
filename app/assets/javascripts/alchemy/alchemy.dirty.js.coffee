window.Alchemy = {} if typeof (window.Alchemy) is "undefined"

$.extend Alchemy,

  ElementDirtyObserver: (selector) ->
    $elements = $(selector)
    $elements.find('input[type="text"], select').change ->
      $this = $(this)
      $this.addClass('dirty')
      Alchemy.setElementDirty $this.parents(".element_editor")
    $elements.find('.element_foot input[type="checkbox"]').click ->
      $this = $(this)
      $this.addClass "dirty"
      Alchemy.setElementDirty $this.parents(".element_editor")

  setElementDirty: (element) ->
    $element = $(element)
    $element
      .addClass('dirty')
      .find('.element_head .icon[class*="element_"]')
      .addClass('element_dirty')
    window.onbeforeunload = @pageUnload

  pageUnload: ->
    Alchemy.pleaseWaitOverlay(false)
    Alchemy._t('page_dirty_notice')

  setElementClean: (element) ->
    $element = $(element)
    $element
      .removeClass('dirty')
      .find('.element_foot input[type="checkbox"], input[type="text"], select')
      .removeClass('dirty')
    $element.find('.element_head .icon').removeClass('element_dirty')
    window.onbeforeunload = undefined

  isPageDirty: ->
    $('#element_area').find('.element_editor.dirty').length > 0

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
