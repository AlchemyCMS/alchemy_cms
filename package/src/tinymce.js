// Alchemy Tinymce wrapper
//

export default {
  customConfigs: {},

  // Returns default config for a tinymce editor.
  //
  getDefaultConfig(id) {
    const config = Alchemy.TinymceDefaults
    config.language = Alchemy.locale
    config.selector = `#tinymce_${id}`
    config.init_instance_callback = this.initInstanceCallback
    return config
  },

  // Returns configuration for given custom tinymce editor selector.
  //
  // It uses the +.getDefaultConfig+ and merges the custom parts.
  //
  getConfig(id, selector) {
    const editor_config = this.customConfigs[selector]
    if (editor_config) {
      return $.extend({}, this.getDefaultConfig(id), editor_config)
    } else {
      return this.getDefaultConfig(id)
    }
  },

  // Initializes all TinyMCE editors with given ids
  //
  // @param ids [Array]
  //   - Editor ids that should be initialized.
  //
  init(ids) {
    ids.forEach((id) => this.initEditor(id))
  },

  // Initializes TinyMCE editor with given options
  //
  initWith(options) {
    tinymce.init($.extend({}, Alchemy.TinymceDefaults, options))
  },

  // Initializes one specific TinyMCE editor
  //
  // @param id [Number]
  //   - Editor id that should be initialized.
  //
  initEditor(id) {
    const editor_id = `tinymce_${id}`
    const textarea = $(`#${editor_id}`)
    const editor = tinymce.get(editor_id)

    // remove editor instance, if already initialized
    if (editor) {
      editor.remove()
    }
    if (textarea.length === 0) {
      console.warn(`Could not initialize TinyMCE for textarea#tinymce_${id}!`)
      return
    }
    const config = this.getConfig(id, textarea[0].classList[1])
    if (config) {
      const spinner = new Alchemy.Spinner("small")
      textarea.closest(".tinymce_container").prepend(spinner.spin().el)
      tinymce.init(config)
    } else {
      console.warn("No tinymce configuration found for", id)
    }
  },

  // Gets called after an editor instance gets initialized
  //
  initInstanceCallback(editor) {
    const $this = $(`#${editor.id}`)
    const element = $this.closest(".element-editor")
    element.find(".spinner").remove()
    editor.on("dirty", function () {
      Alchemy.setElementDirty(element)
    })
    editor.on("click", function (event) {
      event.target = element[0]
      Alchemy.ElementEditors.onClickElement(event)
    })
  },

  // Removes the TinyMCE editor from given dom ids.
  //
  remove(ids) {
    ids.forEach((id) => {
      const editor = tinymce.get(`tinymce_${id}`)
      if (editor) {
        editor.remove()
      }
    })
  },

  // Remove all tinymce instances for given selector
  removeFrom(selector) {
    $(selector).each(function () {
      const elem = tinymce.get(this.id)
      if (elem) {
        elem.remove()
      }
    })
  }
}
