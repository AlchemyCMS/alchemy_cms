window.Alchemy = Alchemy || {}

Alchemy.PreviewElements = {
  styles: {
    reset: {
      outline: "",
      "outline-offset": "",
      cursor: ""
    },
    hover: {
      outline: "2px dashed #f0b437",
      "outline-offset": "4px",
      cursor: "pointer"
    },
    selected: {
      outline: "2px dashed #90b9d0",
      "outline-offset": "4px"
    }
  },
  init: function(selector) {
    if (selector == undefined) {
      selector = "[data-alchemy-element]"
    }

    window.addEventListener("message", function(event) {
      if (event.origin !== window.location.origin) {
        console.warn("Unsafe message origin!", event.origin)
        return
      }
      switch (event.data.message) {
        case "Alchemy.blurElements":
          this.blurElements()
          break
        case "Alchemy.focusElement":
          this.focusElement(event.data)
          break
        case "Alchemy.updateElement":
          this.updateElement(event.data)
          break
        default:
          console.info("Received unknown message!", event.data)
          break
      }
    }.bind(this))

    this.elements = document.querySelectorAll(selector)
    this.elements.forEach(function(element) {
      element.addEventListener('mouseover', function() {
        if (!element.classList.contains('selected')) {
          Object.assign(element.style, this.getStyle('hover'))
        }
      }.bind(this))

      element.addEventListener('mouseout', function() {
        if (!element.classList.contains('selected')) {
          Object.assign(element.style, this.getStyle('reset'))
        }
      }.bind(this))

      element.addEventListener('SelectPreviewElement.Alchemy', function() {
        this.selectElement(element)
      }.bind(this))

      element.addEventListener('click', function(e) {
        e.stopPropagation()
        e.preventDefault()
        this.selectElement(element)
        this.focusElementEditor(element)
      }.bind(this))
    }.bind(this))
  },
  // Updates a preview element with given content
  updateElement: function(data) {
    var element = this.getElement(data.element_id)

    if (element) {
      element.innerHTML = data.content
    } else {
      this.missingElementWarning(data.element_id)
    }
  },
  // Mark element in preview frame as selected and scrolls to it.
  selectElement: function(element) {
    this.blurElements()
    window.parent.Alchemy.currentPreviewElement = element
    element.classList.add('selected')
    Object.assign(element.style, this.getStyle('selected'))
    element.scrollIntoView({
      behavior: 'smooth',
      block: 'start'
    })
  },
  // Blur all elements in preview frame.
  blurElements: function() {
    this.elements.forEach(function(element) {
      element.classList.remove('selected')
      Object.assign(element.style, this.getStyle('reset'))
    }.bind(this))
  },
  // Focus the element in the Alchemy preview window.
  focusElement: function(data) {
    var element = this.getElement(data.element_id)

    if (element) {
      this.selectElement(element)
    } else {
      console.warn('Could not focus element with id', data.element_id)
    }
  },
  getElement: function(element_id) {
    return this.elements.find(function(element) {
      return element.dataset.alchemyElement === element_id.toString()
    })
  },
  // Focus the element editor in the Alchemy element window.
  focusElementEditor: function(element) {
    var element_id = element.getAttribute('data-alchemy-element')
    window.parent.postMessage({
      message: 'Alchemy.focusElementEditor',
      element_id: element_id
    }, window.location.origin)
  },
  getStyle: function(state) {
    return this.styles[state]
  },
  missingElementWarning: function(element_id) {
    console.warn("Alchemy Element with id " + element_id + " not found! Make sure to add [data-alchemy-element] to the element you want to update.")
    console.warn('Current loaded Alchemy Elements', this.elements)
  }
}
