window.Alchemy = {} if typeof (window.Alchemy) is "undefined"

Alchemy.Growler =

  build: (message, flash_type) ->
    $flash_container = $("<div class=\"flash #{flash_type}\" />")
    $flash_container.append Alchemy.messageIcon(flash_type)
    $flash_container.append message
    $("#flash_notices").append $flash_container
    $("#flash_notices").show()
    Alchemy.Growler.fade()

  fade: ->
    $(".flash:not(.error)", "#flash_notices").delay(5000).queue(-> Alchemy.Growler.dismiss(this))
    $(".flash", "#flash_notices").click((e) => @dismiss(e.currentTarget))
    return

  dismiss: (element) ->
    $(element).on 'transitionend', => $(element).remove()
    $(element).addClass('dismissed')
    return

Alchemy.growl = (message, style = "notice") ->
  Alchemy.Growler.build message, style
