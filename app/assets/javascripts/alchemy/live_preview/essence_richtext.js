//= require alchemy/live_preview

window.Alchemy.LivePreview.EssenceRichtext = {
  update: function(element, data) {
    element.innerHTML = data.value
  }
}
