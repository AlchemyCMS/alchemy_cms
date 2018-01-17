#= require alchemy/alchemy.browser
#= require alchemy/alchemy.i18n

window.Alchemy = Alchemy || {}

Alchemy.initAlchemyPreviewMode = ->

  # The Alchemy JavaScript Object contains all Functions
  Object.assign Alchemy,

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
        @elements = document.querySelectorAll("[data-alchemy-element]")
        @elements.forEach (element) =>
          element.addEventListener 'mouseover', =>
            element.setAttribute('title', Alchemy.t('click_to_edit'))
            unless element.classList.contains('selected')
              Object.assign element.style, @getStyle('hover')
            return
          element.addEventListener 'mouseout', =>
            element.removeAttribute('title')
            unless element.classList.contains('selected')
              Object.assign element.style, @getStyle('reset')
            return
          element.addEventListener 'SelectPreviewElement.Alchemy', =>
            @selectElement(element)
            return
          , false
          element.addEventListener 'click', (e) =>
            e.stopPropagation()
            e.preventDefault()
            @selectElement(element)
            @focusElementEditor(element)
            return
          return
        return

      # Mark element in preview frame as selected and scrolls to it.
      selectElement: (element) ->
        @blurElements()
        element.classList.add('selected')
        Object.assign element.style, @getStyle('selected')
        element.scrollIntoView
          behavior: 'smooth'
          block: 'start'
        return

      # Blur all elements in preview frame.
      blurElements: ->
        @elements.forEach (element) =>
          element.classList.remove('selected')
          Object.assign element.style, @getStyle('reset')
          return
        return

      # Focus the element editor in the Alchemy element window.
      focusElementEditor: (element) ->
        alchemy_window = window.parent
        target_id = element.getAttribute('data-alchemy-element')
        $element_editor = alchemy_window.$("#element_#{target_id}")
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
            Object.assign(default_state_style, @styles["#{browser}_#{state}"])
          else
            default_state_style

  Alchemy.ElementSelector.init()

Alchemy.initAlchemyPreviewMode()
