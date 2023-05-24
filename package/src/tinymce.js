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
  const editorConfig = tinymceCustomConfigs[selector] || {}
  return {...getDefaultConfig(id), ...editorConfig};
}

// Initializes one specific TinyMCE editor
//
// @param id [Number]
//   - Editor id that should be initialized.
//
function initEditor(id) {
  const editorId = `tinymce_${id}`
  const textarea = document.getElementById(editorId)
  const editor = tinymce.get(editorId)

  if (textarea === null) {
    console.warn(`Could not initialize TinyMCE for textarea#tinymce_${id}!`)
    return
  }

  // remove editor instance, if already initialized
  if (editor) {
    editor.remove()
  }

  const config = getConfig(id, textarea.classList[1])
  if (config) {
    const spinner = new Alchemy.Spinner("small")
    textarea.closest(".tinymce_container").prepend(spinner.spin().el.get(0))
    tinymce.init(config)
  } else {
    console.warn("No tinymce configuration found for", id)
  }
}

// Gets called after an editor instance gets initialized
//
function initInstanceCallback(editor) {
  const element = document.getElementById(editor.id).closest(".element-editor")
  element.getElementsByClassName("spinner").item(0).remove()
  editor.on("dirty", function () {
    Alchemy.setElementDirty(element)
  })
  editor.on("click", function (event) {
    event.target = element
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
    tinymce.init({...Alchemy.TinymceDefaults, ...options})
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
    // the selector is a jQuery selector - it has to be refactor if we taking care of the calling methods
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
