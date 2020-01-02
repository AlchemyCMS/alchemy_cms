//= require alchemy/preview_elements
//= require alchemy/live_preview

window.Alchemy = Alchemy || {}

Alchemy.initAlchemyPreviewMode = function() {
  Alchemy.PreviewElements.init()
  Alchemy.LivePreview.init()
}

Alchemy.initAlchemyPreviewMode()
