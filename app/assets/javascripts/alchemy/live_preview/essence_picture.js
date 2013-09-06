//= require alchemy/live_preview

window.Alchemy.LivePreview.EssencePicture = {
  update: function(element, data) {
    var image = new Image()

    element.innerHTML = null
    if (data.value) {
      image.src = data.value
      element.appendChild(image)
    }
  }
}
