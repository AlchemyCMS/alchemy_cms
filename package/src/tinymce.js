// Alchemy Tinymce wrapper
//

let tinymceCustomConfigs = {}
let tinymceIntersectionObserver = null

// Returns default config for a tinymce editor.
function getDefaultConfig(editorId) {
  const config = Alchemy.TinymceDefaults
  config.language = Alchemy.locale
  config.selector = `#${editorId}`
  config.init_instance_callback = initInstanceCallback
  return config
}

// Returns configuration for given custom tinymce editor selector.
//
// It uses the +.getDefaultConfig+ and merges the custom parts.
function getConfig(id, selector) {
  const editorConfig = tinymceCustomConfigs[selector] || {}
  return { ...getDefaultConfig(id), ...editorConfig }
}

// create intersection observer and register textareas to be initialized when
// they are visible
function initEditors(ids) {
  initializeIntersectionObserver()

  ids.forEach((id) => {
    const editorId = `tinymce_${id}`
    const textarea = document.getElementById(editorId)

    if (textarea) {
      tinymceIntersectionObserver.observe(textarea)
    } else {
      console.warn(`Could not initialize TinyMCE for textarea#${editorId}!`)
    }
  })
}

// initialize IntersectionObserver if it is not already initialized
// the observer will initialize Tinymce if the textarea becomes visible
function initializeIntersectionObserver() {
  if (tinymceIntersectionObserver === null) {
    const observerCallback = (entries, observer) => {
      entries.forEach((entry) => {
        if (entry.intersectionRatio > 0) {
          initTinymceEditor(entry.target)
          // disable observer after the Tinymce was initialized
          observer.unobserve(entry.target)
        }
      })
    }
    const options = {
      root: Alchemy.ElementEditors.element_area.get(0),
      rootMargin: "0px",
      threshold: [0.05]
    }

    tinymceIntersectionObserver = new IntersectionObserver(
      observerCallback,
      options
    )
  }
}

// Initializes one specific TinyMCE editor
function initTinymceEditor(textarea) {
  const editorId = textarea.id
  const config = getConfig(editorId, textarea.classList[1])

  // remove editor instance, if already initialized
  removeEditor(editorId)

  if (config) {
    const spinner = new Alchemy.Spinner("small")
    textarea.closest(".tinymce_container").prepend(spinner.spin().el.get(0))
    tinymce.init(config)
  } else {
    console.warn("No tinymce configuration found for", id)
  }
}

// Gets called after an editor instance gets initialized
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

function removeEditor(editorId) {
  const editorElement = document.getElementById(editorId)
  if (tinymceIntersectionObserver && editorElement) {
    tinymceIntersectionObserver.unobserve(editorElement)
  }

  const editor = tinymce.get(editorId)
  if (editor) {
    editor.remove()
  }
}

export default {
  // Initializes all TinyMCE editors with given ids
  //
  // @param ids [Array]
  //   - Editor ids that should be initialized.
  init(ids) {
    initEditors(ids)
  },

  // Initializes TinyMCE editor with given options
  initWith(options) {
    tinymce.init({ ...Alchemy.TinymceDefaults, ...options })
  },

  // Removes the TinyMCE editor from given dom ids.
  remove(ids) {
    ids.forEach((id) => removeEditor(`tinymce_${id}`))
  },

  // Remove all tinymce instances for given selector
  removeFrom(selector) {
    // the selector is a jQuery selector - it has to be refactor if we taking care of the calling methods
    $(selector).each(function (element) {
      removeEditor(element.id)
    })
  },

  // set tinymce configuration for a given selector key
  setCustomConfig(key, configuration) {
    tinymceCustomConfigs[key] = configuration
  }
}
