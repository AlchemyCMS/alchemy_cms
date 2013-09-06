//= require alchemy/live_preview

window.Alchemy.LivePreview.EssenceText = {
  update: function(element, data) {
    var link = element.querySelector(':scope > a')
    if (link) {
      element = link
    }
    element.innerText = data.value
  }
}
