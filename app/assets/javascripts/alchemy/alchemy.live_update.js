window.Alchemy = Alchemy || {}

// Responsible for the live preview feature
window.Alchemy.LiveUpdate = {
  // Store the currently binded rtf editor instance
  currentBindedRTFEditors: [],

  // Cache of current EssenceDate mutation observers
  mutationObservers: [],

  // Binds live editing events for given element
  bind: function($element) {
    this.bindEssenceTextUpdates($element)
    this.bindEssenceRichtextUpdates($element)
    this.bindEssencePictureUpdates($element)
    this.bindEssenceDateUpdates($element)
    this.bindEssenceBooleanUpdates($element)
    this.bindEssenceSelectUpdates($element)
  },

  // Updates the content of the currently edited EssenceText in the preview window
  bindEssenceTextUpdates: function($element) {
    var onKeyUp = function(event) {
      var input = event.target

      this.updateContent({
        content_id: input.dataset.alchemyContentId,
        essence_type: 'EssenceText',
        value: input.value
      })
    }.bind(this)

    // unbind keyup events of all other elements
    $('.essence_text.content_editor input[type="text"]').off('keyup', onKeyUp)
    // rebind for current element
    $('.essence_text.content_editor input[type="text"]', $element).on('keyup', onKeyUp)
  },

  // Updates the content of the currently edited EssenceRichtext in the preview window
  bindEssenceRichtextUpdates: function($element) {
    $('.essence_richtext.content_editor textarea', $element).each(function(_i, textarea) {
      var rtf_id = $(textarea).attr('id')

      if (rtf_id && !this.currentBindedRTFEditors.includes(rtf_id)) {
        var editor = tinymce.get(rtf_id)

        this.currentBindedRTFEditors.push(rtf_id)
        editor.on('keyup Change Undo Redo', function() {
          this.updateContent({
            content_id: textarea.dataset.alchemyContentId,
            essence_type: 'EssenceRichtext',
            value: editor.getContent()
          })
        }.bind(this))
      }
    }.bind(this))
  },

  // Updates the content of the currently edited picture element in the preview window
  bindEssencePictureUpdates: function($element) {
    var onPictureChange = function(_e, content_id, url) {
      this.updateContent({
        content_id: content_id,
        essence_type: 'EssencePicture',
        value: url
      })
    }.bind(this)

    var onPictureRemove = function(_e, content_id) {
      this.updateContent({
        content_id: content_id,
        essence_type: 'EssencePicture',
        value: null
      })
    }.bind(this)

    $('.element_editor').off('PictureChange.Alchemy', onPictureChange)
    $element.on('PictureChange.Alchemy', onPictureChange)

    $('.element_editor').off('RemovePicture.Alchemy', onPictureRemove)
    $element.on('RemovePicture.Alchemy', onPictureRemove)
  },

  // Updates the content of the currently edited EssenceDate in the preview window
  bindEssenceDateUpdates: function($element) {
    this.mutationObservers.forEach(function(observer) { observer.disconnect() })
    $element.find('.essence_date.content_editor input[type="hidden"]').each(function(_i, input) {
      var observer = new MutationObserver(function(mutations) {
        if (mutations[0].attributeName === "value") {
          this.updateContent({
            content_id: input.dataset.alchemyContentId,
            essence_type: 'EssenceDate',
            value: input.value
          })
        }
      }.bind(this))

      observer.observe(input, { attributes: true })
      this.mutationObservers.push(observer)
    }.bind(this))
  },

  // Updates the content of the currently edited EssenceBoolean in the preview window
  bindEssenceBooleanUpdates: function($element) {
    var onChange = function(event) {
      var checkbox = event.target
      var data = checkbox.dataset

      this.updateContent({
        content_id: data.alchemyContentId,
        essence_type: 'EssenceBoolean',
        value: checkbox.checked ? data.trueValue : data.falseValue
      })
    }.bind(this)

    // unbind keyup events of all other elements
    $('.essence_boolean.content_editor input[type="checkbox"]').off('change', onChange)
    // rebind for current element
    $('.essence_boolean.content_editor input[type="checkbox"]', $element).on('change', onChange)
  },

  // Updates the content of the currently edited EssenceSelect in the preview window
  bindEssenceSelectUpdates: function($element) {
    var onChange = function(event) {
      var select = event.target

      this.updateContent({
        content_id: select.dataset.alchemyContentId,
        essence_type: 'EssenceSelect',
        value: select.value
      })
    }.bind(this)

    // unbind keyup events of all other elements
    $('.essence_select.content_editor select').off('change', onChange)
    // rebind for current element
    $('.essence_select.content_editor select', $element).on('change', onChange)
  },

  // Updates a preview element with given content
  updateElement: function(element_id, content) {
    Alchemy.PreviewWindow.postMessage({
      message: 'Alchemy.updateElement',
      element_id: element_id,
      content: content
    })
  },

  updateContent: function(data) {
    data.message = 'Alchemy.updateContent'
    Alchemy.PreviewWindow.postMessage(data)
  }
}
