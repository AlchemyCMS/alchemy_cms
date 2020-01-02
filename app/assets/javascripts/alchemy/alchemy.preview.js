//= require alchemy/preview_elements
//= require alchemy/live_preview

window.Alchemy = Alchemy || {}

Alchemy.initAlchemyPreviewMode = function(window) {
  Alchemy.PreviewElements.init()
  Alchemy.LivePreview.init()

  window.addEventListener("message", function (event) {
    if (event.origin !== window.location.origin) {
      console.warn("Unsafe message origin!", event.origin)
      return
    }

    switch (event.data.message) {
      case "Alchemy.blurElements":
        Alchemy.PreviewElements.blurElements()
        break
      case "Alchemy.focusElement":
        Alchemy.PreviewElements.focusElement(event.data)
        break
      case "Alchemy.updateElement":
        Alchemy.PreviewElements.updateElement(event.data)
        break
      case "Alchemy.updateContent":
        Alchemy.LivePreview.update(event.data)
        break
      default:
        console.info("Received unknown message!", event.data)
        break
    }
  })
}

Alchemy.initAlchemyPreviewMode(window)
