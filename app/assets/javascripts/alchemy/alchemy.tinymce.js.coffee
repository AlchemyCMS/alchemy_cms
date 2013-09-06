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

  # Returns configuration for given custom tinymce editor selector.
  #
  # It uses the +.getDefaultConfig+ and merges the custom parts.
  #
  getConfig: (id, selector) ->
    editor_config = @customConfigs[selector]
    if editor_config
      $.extend({}, @getDefaultConfig(id), editor_config)
    else
      @getDefaultConfig(id)

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
  #
  initEditor: (id) ->
    editor_id = "tinymce_#{id}"
    textarea = $("##{editor_id}")
    editor = tinymce.get(editor_id)
    # remove editor instance, if already initialized
    editor.remove() if editor
    if textarea.length == 0
      console.warn "Could not initialize TinyMCE for textarea#tinymce_#{id}!"
      return
    config = @getConfig(id, textarea[0].classList[1])
    if config
      spinner = new Alchemy.Spinner('small')
      textarea.closest('.tinymce_container').prepend spinner.spin().el
      tinymce.init(config)
    else
      console.warn('No tinymce configuration found for', id)

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
      editor_id = "tinymce_#{id}"
      @unbindLivePreview(editor_id)
      editor = tinymce.get(editor_id)
      if editor
        editor.remove()

  # Remove all tinymce instances for given selector
  removeFrom: (selector) ->
    $(selector).each (_i, element) =>
      editor = tinymce.get(element.id)
      editor.remove() if editor
      @unbindLivePreview(element.id)
      return
    return

  unbindLivePreview: (editor_id) ->
    arr = Alchemy.LivePreview.currentBindedRTFEditors
    idx = arr.indexOf(editor_id)
    arr.splice(idx, 1) unless idx == -1
