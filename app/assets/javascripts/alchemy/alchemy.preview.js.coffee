#= require alchemy/alchemy.jquery_loader
#= require alchemy/alchemy.browser
#= require alchemy/alchemy.i18n

window.Alchemy = {} if typeof(Alchemy) is 'undefined'

Alchemy.initAlchemyPreviewMode = ($) ->

  # Setting jQueryUIs global animation duration
  $.fx.speeds._default = 400

  # The Alchemy JavaScript Object contains all Functions
  $.extend Alchemy,
    ElementSelector:

      # defaults
      scrollOffset: 20

      styles:
        reset:
          outline: ""
          "outline-offset": ""
          "-moz-outline-radius": ""

        default_hover:
          outline: "3px solid #F0B437"
          "outline-offset": "4px"
          cursor: "pointer"

        webkit_hover:
          outline: "4px auto #F0B437"

        moz_hover:
          "-moz-outline-radius": "3px"

        default_selected:
          outline: "3px solid #90B9D0"
          "outline-offset": "4px"

        webkit_selected:
          outline: "4px auto #90B9D0"

        moz_selected:
          "-moz-outline-radius": "3px"

      init: ->
        $elements = $("[data-alchemy-element]")
        @$previewElements = $elements
        $elements.mouseover (e) =>
          $el = $(e.delegateTarget)
          $el.attr("title", Alchemy._t('click_to_edit'))
          $el.css(@getStyle("hover")) unless $el.hasClass("selected")
        $elements.mouseout (e) =>
          $el = $(e.delegateTarget)
          $el.removeAttr("title")
          $el.css(@getStyle("reset")) unless $el.hasClass("selected")
        $elements.on "Alchemy.SelectElement", (e) =>
          @selectElement(e)
        $elements.click (e) =>
          @clickElement(e)

      selectElement: (e) ->
        $el = $(e.delegateTarget)
        $elements = @$previewElements
        offset = @scrollOffset
        e.preventDefault()
        $elements.removeClass("selected").css(@getStyle("reset"))
        $el.addClass("selected").css(@getStyle("selected"))
        $("html, body").animate
          scrollTop: $el.offset().top - offset
          scrollLeft: $el.offset().left - offset
        , 400
        return

      clickElement: (e) ->
        $el = $(e.delegateTarget)
        parent$ = window.parent.jQuery
        target_id = $el.data("alchemy-element")
        $element_editor = parent$("#element_area .element_editor").closest("[id=\"element_" + target_id + "\"]")
        elementsWindow = window.parent.Alchemy.ElementsWindow
        e.preventDefault()
        $element_editor.trigger("Alchemy.SelectElementEditor", target_id)
        if elementsWindow.hidden
          elementsWindow.show()
        $el.trigger("Alchemy.SelectElement")
        return

      getStyle: (state) ->
        if state == "reset"
          @styles["reset"]
        else
          default_state_style = @styles["default_#{state}"]
          browser = "webkit" if Alchemy.Browser.isWebKit
          browser = "moz" if Alchemy.Browser.isFirefox
          if browser
            $.extend(default_state_style, @styles["#{browser}_#{state}"])
          else
            default_state_style

  Alchemy.ElementSelector.init()

if typeof(jQuery) is 'undefined'
  Alchemy.loadjQuery(Alchemy.initAlchemyPreviewMode)
else
  Alchemy.initAlchemyPreviewMode(jQuery)
