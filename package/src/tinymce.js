// Alchemy Tinymce wrapper
//

let tinymceCustomConfigs = {}

// Returns default config for a tinymce editor.
function getDefaultConfig(id) {
  const config = Alchemy.TinymceDefaults
  config.language = Alchemy.locale
  config.selector = `#tinymce_${id}`
  config.init_instance_callback = initInstanceCallback
  return config
}

// Returns configuration for given custom tinymce editor selector.
//
// It uses the +.getDefaultConfig+ and merges the custom parts.
//
function getConfig(id, selector) {
  const editor_config = tinymceCustomConfigs[selector]
  if (editor_config) {
    return $.extend({}, getDefaultConfig(id), editor_config)
  } else {
    return getDefaultConfig(id)
  }
}

// Initializes one specific TinyMCE editor
//
// @param id [Number]
//   - Editor id that should be initialized.
//
function initEditor(id) {
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
  const config = getConfig(id, textarea[0].classList[1])
  if (config) {
    const spinner = new Alchemy.Spinner("small")
    textarea.closest(".tinymce_container").prepend(spinner.spin().el)
    tinymce.init(config)
  } else {
    console.warn("No tinymce configuration found for", id)
  }
}

// Gets called after an editor instance gets initialized
//
function initInstanceCallback(editor) {
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
}

export default {

  // Initializes all TinyMCE editors with given ids
  //
  // @param ids [Array]
  //   - Editor ids that should be initialized.
  //
  init(ids) {
    ids.forEach((id) => initEditor(id))
  },

  // Initializes TinyMCE editor with given options
  //
  initWith(options) {
    tinymce.init($.extend({}, Alchemy.TinymceDefaults, options))
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
  },

  // set tinymce configuration for a given selector key
  setCustomConfig(key, configuration) {
    tinymceCustomConfigs[key] = configuration;
  }
}
