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
          return
        $elements.mouseout (e) =>
          $el = $(e.delegateTarget)
          $el.removeAttr("title")
          $el.css(@getStyle("reset")) unless $el.hasClass("selected")
          return
        $elements.on "SelectPreviewElement.Alchemy", (e) =>
          $el = $(e.delegateTarget)
          # Stop the event from bubbling up to parent elements
          e.stopPropagation()
          @selectElement($el)
          return
        $elements.click (e) =>
          $el = $(e.delegateTarget)
          # Stop the event from bubbling up to parent elements
          e.stopPropagation()
          # Stop default click events from running
          e.preventDefault()
          # Mark current preview element as selected
          @selectElement($el)
          # Focus the element editor
          @focusElementEditor($el)
          return
        return

      # Mark element in preview frame as selected and scrolls to it.
      selectElement: ($el) ->
        offset = $el.offset()
        @$previewElements.removeClass("selected").css(@getStyle("reset"))
        $el.addClass("selected").css(@getStyle("selected"))
        $("html, body").animate
          scrollTop: offset.top - @scrollOffset
          scrollLeft: offset.left - @scrollOffset
        , 400
        return

      # Focus the element editor in the Alchemy element window.
      focusElementEditor: ($el) ->
        alchemy_window = window.parent
        alchemy_$ = alchemy_window.jQuery
        target_id = $el.data("alchemy-element")
        $element_editor = alchemy_$("#element_#{target_id}")
        elements_window = alchemy_window.Alchemy.ElementsWindow
        $element_editor.trigger("FocusElementEditor.Alchemy", target_id)
        elements_window.show() if elements_window.hidden
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
