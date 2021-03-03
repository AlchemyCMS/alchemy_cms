# Alchemy Tinymce wrapper
#
$.extend Alchemy.Tinymce,

  customConfigs: {}

  # Returns default config for a tinymce editor.
  #
  getDefaultConfig: (id) ->
    config = @defaults
    config.language = Alchemy.locale
    config.selector = "#tinymce_#{id}"
    config.init_instance_callback = @initInstanceCallback
    return config

  # Initializes all TinyMCE editors with given ids
  #
  # @param ids [Array]
  #   - Editor ids that should be initialized.
  #
  init: (ids) ->
    for id in ids
      @initEditor(id)

  # Initializes TinyMCE editor with given options
  #
  initWith: (options) ->
    tinymce.init $.extend({}, @defaults, options)
    return

  # Initializes one specific TinyMCE editor
  #
  # @param id [Number]
  #   - Editor id that should be initialized.
  # @param customConfig [Object]
  #   - Configuration that should be used instead of the default one.
  #
  initEditor: (id, customConfig) ->
    config = @getDefaultConfig(id)
    editor_id = "tinymce_#{id}"
    textarea = $("##{editor_id}")
    editor = tinymce.get(editor_id)
    # remove editor instance, if already initialized
    editor.remove() if editor
    if textarea.length == 0
      console.warn "Could not initialize TinyMCE for textarea#tinymce_#{id}!"
      return
    if customConfig
      config = $.extend({}, config, customConfig)
    spinner = new Alchemy.Spinner('small')
    textarea.closest('.tinymce_container').prepend spinner.spin().el
    tinymce.init(config)

  # Gets called after an editor instance gets intialized
  #
  initInstanceCallback: (editor) ->
    $this = $("##{editor.id}")
    element = $this.closest('.element-editor')
    element.find('.spinner').remove()
    editor.on 'dirty', ->
      Alchemy.setElementDirty(element)
      return
    editor.on 'click', (event) ->
      event.target = element[0]
      Alchemy.ElementEditors.onClickElement(event)
      return
    return

  # Removes the TinyMCE editor from given dom ids.
  #
  remove: (ids) ->
    for id in ids
      editor = tinymce.get("tinymce_#{id}")
      if editor
        editor.remove()

  # Remove all tinymce instances for given selector
  removeFrom: (selector) ->
    $(selector).each ->
      elem = tinymce.get(this.id)
      elem.remove() if elem
      return
    return
