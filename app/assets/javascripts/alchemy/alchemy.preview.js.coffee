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
          switch event.data.message
            when "Alchemy.blurElements" then @blurElements()
            when "Alchemy.focusElement" then @focusElement(event.data)
            else console.info("Received unknown message!", event.data)
          return
        @elements = Array.from document.querySelectorAll("[data-alchemy-element]")
        @elements.forEach (element) =>
          element.addEventListener 'mouseover', =>
            unless element.classList.contains('selected')
              Object.assign element.style, @getStyle('hover')
            return
          element.addEventListener 'mouseout', =>
            unless element.classList.contains('selected')
              Object.assign element.style, @getStyle('reset')
            return
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

      # Focus the element in the Alchemy preview window.
      focusElement: (data) ->
        element = @getElement(data.element_id)
        if element
          @selectElement(element)
        else
          console.warn('Could not focus element with id', data.element_id)

      getElement: (element_id) ->
        @elements.find (element) ->
          element.dataset.alchemyElement == element_id.toString()

      # Focus the element editor in the Alchemy element window.
      focusElementEditor: (element) ->
        element_id = element.getAttribute('data-alchemy-element')
        window.parent.postMessage
          message: 'Alchemy.focusElementEditor'
          element_id: element_id
        , window.location.origin
        return

      getStyle: (state) ->
        if state == "reset"
          @styles["reset"]
        else
          @styles[state]

  Alchemy.ElementSelector.init()

Alchemy.initAlchemyPreviewMode()
