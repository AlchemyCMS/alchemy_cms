# Alchemy Tinymce wrapper
#
$.extend Alchemy.Tinymce,

  # Returns default config for a tinymce editor.
  #
  getDefaultConfig: (id) ->
    config = @defaults
    config.language = Alchemy.locale
    config.selector = "textarea#tinymce_#{id}"
    config.init_instance_callback = @initInstanceCallback
    return config

  # Returns configuration for given custom tinymce editor selector.
  #
  # It uses the +.getDefaultConfig+ and merges the custom parts.
  #
  getCustomConfig: (id, selector) ->
    editor_config = @customConfigs[selector]
    if editor_config
      $.extend({}, @getDefaultConfig(id), editor_config)

  # Initializes all TinyMCE editors with given ids
  #
  # @param ids [Array]
  #   - Editor ids that should be initialized.
  #
  init: (ids) ->
    for id in ids
      @initEditor(id)

  # Initializes one specific TinyMCE editor
  #
  # @param id [Number]
  #   - Editor id that should be initialized.
  #
  initEditor: (id) ->
    textarea = $("textarea#tinymce_#{id}")
    return if textarea.length == 0
    if selector = textarea[0].classList[1]
      config = @getCustomConfig(id, selector)
    else
      config = @getDefaultConfig(id)
    if config
      spinner = Alchemy.Spinner.small()
      textarea.parents('.tinymce_container').prepend spinner.spin().el
      tinymce.init(config)
    else
      Alchemy.debug('No tinymce configuration found for', id)

  # Gets called after an editor instance gets intialized
  #
  initInstanceCallback: (inst) ->
    $this = $("##{inst.id}")
    parent = $this.parents('.element_editor')
    parent.find('.spinner').remove()
    inst.on 'change', (e) ->
      Alchemy.setElementDirty(parent)

  # Removes the TinyMCE editor from given dom ids.
  #
  remove: (ids) ->
    for id in ids
      editor = tinymce.get("tinymce_#{id}")
      if editor
        editor.remove()
