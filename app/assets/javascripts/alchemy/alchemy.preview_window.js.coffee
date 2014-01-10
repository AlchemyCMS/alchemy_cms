window.Alchemy = {} if typeof(window.Alchemy) is 'undefined'

Alchemy.PreviewWindow =

  init: (url, title) ->
    $iframe = $("#alchemyPreviewWindow")
    if $iframe.length is 0
      $iframe = $("<iframe name=\"alchemyPreviewWindow\" src=\"#{url}\" id=\"alchemyPreviewWindow\" frameborder=\"0\"/>")
      $iframe.load ->
        $(".preview-refresh-spinner").hide()
        $(".ui-dialog-titlebar-refresh").show()
      $iframe.css "background-color": "#ffffff"
      Alchemy.PreviewWindow.currentWindow = $iframe.dialog(
        modal: false
        title: title
        minWidth: 240
        minHeight: 300
        width: $(window).width() - 482
        height: $(window).height() - 76
        show: "fade"
        hide: "fade"
        position: [70, 84]
        autoResize: true
        closeOnEscape: false
        dialogClass: 'alchemy-preview-window'
        create: ->
          $titlebar = $("#alchemyPreviewWindow").prev()
          $titlebar.append Alchemy.PreviewWindow.reloadButton()
          spinner = Alchemy.Spinner.small(className: "preview-refresh-spinner")
          $titlebar.append spinner.spin().el
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

  refresh: (callback) ->
    $iframe = $("#alchemyPreviewWindow")
    $spinner = $(".preview-refresh-spinner")
    $refresh = $('.ui-dialog-titlebar-refresh')
    $spinner.show()
    $refresh.hide()
    $iframe.load (e) ->
      $spinner.hide()
      $refresh.show()
      if callback
        callback.call(e, $iframe)
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

  reloadButton: ->
    $reload = $('<button class="ui-dialog-titlebar-refresh ui-corner-all ui-state-default" role="button" data-alchemy-hotkey="alt+r" />')
    $reload.append('<span class="ui-icon ui-icon-refresh" />')
    $reload.click Alchemy.reloadPreview
    $reload.hover ->
      $(this).toggleClass "ui-state-hover ui-state-default"
    $reload.hide()
    $reload

Alchemy.reloadPreview = ->
  Alchemy.PreviewWindow.refresh()
