//= require_tree ./live_preview/

window.Alchemy = Alchemy || {}

Alchemy.LivePreview = {
  init: function() {
    window.addEventListener("message", this.onMessage.bind(this))
    this.load()
  },
  load: function() {
    nodes = document.querySelectorAll('[data-alchemy-content-id]')
    this.contents = Array.from(nodes)
  },
  getContent: function(data) {
    return this.contents.find(function(content) {
      return content.dataset.alchemyContentId === data.content_id.toString()
    })
  },
  onMessage: function(event) {
    var data = event.data

    if (event.origin !== window.location.origin) {
      return
    }

    if (data.message == "Alchemy.updateContent") {
      this.update(data)
    }
    return true
  },
  update: function(data) {
    var essence_type = data.essence_type
    var essence_updater = Alchemy.LivePreview[essence_type]

    if (essence_updater) {
      this.updateEssence(essence_updater, data)
    } else {
      this.missingEssenceUpdaterWarning(data.essence_type)
    }
  },
  updateEssence: function(essence_updater, data) {
    var content = this.getContent(data)

    if (content) {
      essence_updater.update(content, data)
    } else {
      this.missingContentWarning(data.content_id)
    }
  },
  missingContentWarning: function(content_id) {
    console.warn('Alchemy Content with id ' + content_id + ' not found! Make sure to add [data-alchemy-content-id] to the element you want to update.')
    console.warn('Current loaded Alchemy Contents', this.contents)
  },
  missingEssenceUpdaterWarning: function(essence_type) {
    console.warn('Alchemy essence updater for ' + essence_type + ' not found!')
  }
}
