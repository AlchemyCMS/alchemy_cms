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
      .find('.element_head .icon')
      .addClass('element_dirty')
    window.onbeforeunload = @pageUnload

  pageUnload: ->
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
    okcallback = undefined
    if $(element).is("form")
      okcallback = ->
        $form = $("<form action=\"#{element.action}\" method=\"POST\" style=\"display: none\" />")
        $form.append $(element).find("input")
        $form.appendTo "body"
        Alchemy.pleaseWaitOverlay()
        $form.submit()
    else if $(element).is("a")
      okcallback = ->
        Alchemy.pleaseWaitOverlay()
        document.location = element.pathname
    if Alchemy.isPageDirty()
      Alchemy.pleaseWaitOverlay(false)
      Alchemy.openConfirmWindow
        title: Alchemy._t('warning')
        message: Alchemy._t('page_dirty_notice')
        okLabel: Alchemy._t('ok')
        cancelLabel: Alchemy._t('cancel')
        okCallback: okcallback
      false
    else
      true

  PageLeaveObserver: ->
    $("#main_navi a").click (event) ->
      event.preventDefault() unless Alchemy.checkPageDirtyness(event.currentTarget)
