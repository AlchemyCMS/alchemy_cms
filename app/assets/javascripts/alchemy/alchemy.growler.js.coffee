window.Alchemy = {} if typeof (window.Alchemy) is "undefined"

Alchemy.Growler =

  build: (message, flash_type) ->
    $flash_container = $("<div class=\"flash #{flash_type}\" />")
    icon_class = (if flash_type is "notice" then "tick" else flash_type)
    $flash_container.append "<span class=\"icon-#{icon_class}\" />"
    $flash_container.append message
    $("#flash_notices").append $flash_container
    $("#flash_notices").show()
    Alchemy.Growler.fade()

  fade: ->
    $(".flash.notice, .flash.warning, .flash.warn, .flash.alert", "#flash_notices").delay(5000).hide "drop",
      direction: "up"
    , 400, ->
      $(this).remove()

    $(".flash.error", "#flash_notices").click ->
      $(this).hide "drop",
        direction: "up"
      , 400, ->
        $(this).remove()

Alchemy.growl = (message, style = "notice") ->
  Alchemy.Growler.build message, style
