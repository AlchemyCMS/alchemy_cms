window.Alchemy = Alchemy || {}

Alchemy.initAlchemyPreviewMode = ->

  # The Alchemy JavaScript Object contains all Functions
  Object.assign Alchemy,

    ElementSelector:

      styles:
        reset:
          outline: ""
          "outline-offset": ""
          cursor: ""
        hover:
          outline: "2px dashed #f0b437"
          "outline-offset": "4px"
          cursor: "pointer"
        selected:
          outline: "2px dashed #90b9d0"
          "outline-offset": "4px"

      init: ->
        window.addEventListener "message", (event) =>
          if event.origin != window.location.origin
            console.warn 'Unsafe message origin!', event.origin
            return
          if event.data.message == "Alchemy.blurElements"
            @blurElements()
          return
        @elements = document.querySelectorAll("[data-alchemy-element]")
        @elements.forEach (element) =>
          element.addEventListener 'mouseover', =>
            unless element.classList.contains('selected')
              Object.assign element.style, @getStyle('hover')
            return
          element.addEventListener 'mouseout', =>
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
          @styles[state]

  Alchemy.ElementSelector.init()

Alchemy.initAlchemyPreviewMode()
