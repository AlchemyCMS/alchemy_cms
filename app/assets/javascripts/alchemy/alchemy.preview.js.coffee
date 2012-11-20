window.Alchemy = {}  if typeof (Alchemy) is "undefined"
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
        self = Alchemy.ElementSelector
        $elements = $("[data-alchemy-element]")
        $elements.bind "mouseover", (e) ->
          $(this).attr("title", "Klicken zum bearbeiten")
          $(this).css(self.getStyle("hover")) unless $(this).hasClass("selected")

        $elements.bind "mouseout", ->
          $(this).removeAttr("title")
          $(this).css(self.getStyle("reset")) unless $(this).hasClass("selected")

        $elements.bind("Alchemy.SelectElement", self.selectElement)
        $elements.bind("click", self.clickElement)
        self.$previewElements = $elements

      selectElement: (e) ->
        $this = $(this)
        self = Alchemy.ElementSelector
        $elements = self.$previewElements
        offset = self.scrollOffset
        e.preventDefault()
        $elements.removeClass("selected").css(self.getStyle("reset"))
        $this.addClass("selected").css(self.getStyle("selected"))
        $("html, body").animate
          scrollTop: $this.offset().top - offset
          scrollLeft: $this.offset().left - offset
        , 400
        return

      clickElement: (e) ->
        $this = $(this)
        parent$ = window.parent.jQuery
        target_id = $this.data("alchemy-element")
        $element_editor = parent$("#element_area .element_editor").closest("[id=\"element_" + target_id + "\"]")
        $elementsWindow = parent$("#alchemyElementWindow")
        e.preventDefault()
        $element_editor.trigger("Alchemy.SelectElementEditor", target_id)
        if $elementsWindow.dialog
          if $elementsWindow.dialog("isOpen")
            $elementsWindow.dialog("moveToTop")
          else
            $elementsWindow.dialog "open"
        $this.trigger("Alchemy.SelectElement")
        return

      getStyle: (state) ->
        self = Alchemy.ElementSelector
        if state == "reset"
          self.styles["reset"]
        else
          default_state_style = self.styles["default_#{state}"]
          browser = "webkit" if Alchemy.Browser.isWebKit
          browser = "moz" if Alchemy.Browser.isFirefox
          if browser
            $.extend(default_state_style, self.styles["#{browser}_#{state}"])
          else
            default_state_style

  Alchemy.ElementSelector.init()

if typeof (jQuery) is "undefined"
  Alchemy.loadjQuery(Alchemy.initAlchemyPreviewMode)
else
  Alchemy.initAlchemyPreviewMode(jQuery)
