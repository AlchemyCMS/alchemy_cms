window.Alchemy = {} if typeof(window.Alchemy) is 'undefined'

Alchemy.PreviewWindow =

  init: (url, title) ->
    $iframe = $("#alchemyPreviewWindow")
    if $iframe.length is 0
      $iframe = $("<iframe src=\"#{url}\" id=\"alchemyPreviewWindow\" frameborder=\"0\"/>")
      $iframe.load ->
        $(".preview-refresh-spinner").hide()
      $iframe.css "background-color": "#ffffff"
      Alchemy.PreviewWindow.currentWindow = $iframe.dialog(
        modal: false
        title: title
        width: $(window).width() - 502
        height: $(window).height() - 76
        minWidth: 600
        minHeight: 300
        show: "fade"
        hide: "fade"
        position: [70, 84]
        autoResize: true
        closeOnEscape: false
        dialogClass: 'alchemy-preview-window'
        create: ->
          spinner = Alchemy.Spinner.small(className: "preview-refresh-spinner")
          $reload = $("<button class=\"ui-dialog-titlebar-refresh ui-corner-all ui-state-default\" role=\"button\"></button>")
          $titlebar = $("#alchemyPreviewWindow").prev()
          $reload.append "<span class=\"ui-icon ui-icon-refresh\">reload</span>"
          $titlebar.append $reload
          $titlebar.append spinner.spin().el
          $reload.click Alchemy.reloadPreview
          $reload.hover ->
            $(this).toggleClass "ui-state-hover ui-state-default"
        close: (event, ui) ->
          Alchemy.PreviewWindow.button.enable()
        open: (event, ui) ->
          $(this).css width: "100%"
          Alchemy.PreviewWindow.button.disable()
      ).dialogExtend
          maximize: true
          dblclick: "maximize"
          icons:
            maximize: "ui-icon-fullscreen"
            restore: "ui-icon-exit-fullscreen"
    else
      $("#alchemyPreviewWindow").dialog "open"

  refresh: ->
    $iframe = $("#alchemyPreviewWindow")
    $(".preview-refresh-spinner").show()
    $iframe.load ->
      $(".preview-refresh-spinner").hide()
    $iframe.attr("src", $iframe.attr("src"))
    true

  button:
    enable: ->
      $("div#show_preview_window").removeClass("disabled").find("a").removeAttr "tabindex"

    disable: ->
      $("div#show_preview_window").addClass("disabled").find("a").attr "tabindex", "-1"

    toggle: ->
      if $("div#show_preview_window").hasClass("disabled")
        Alchemy.PreviewWindow.button.enable()
      else
        Alchemy.PreviewWindow.button.disable()

Alchemy.reloadPreview = ->
  Alchemy.PreviewWindow.refresh()
