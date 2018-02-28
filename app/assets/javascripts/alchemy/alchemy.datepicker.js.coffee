window.Alchemy = {} if typeof(window.Alchemy) is 'undefined'

$.extend Alchemy,

  Datepicker: (scope) ->
    $.datetimepicker.setLocale(Alchemy.locale);
    $datepicker_inputs = $('input[data-datepicker-type]', scope)

    # Initializes the datepickers on the text inputs and sets the proper type
    # to enable browsers default datepicker if the current OS is iOS.
    if Alchemy.isiOS
      $datepicker_inputs.prop "type", ->
        return $(this).data('datepicker-type')
    else
      $datepicker_inputs.each ->
        type = $(this).data('datepicker-type')
        options =
          scrollInput: false
          format: Alchemy.t("formats.#{type}")
          timepicker: /time/.test(type)
          datepicker: /date/.test(type)
          dayOfWeekStart: Alchemy.t('formats.start_of_week')
          onSelectDate: ->
            Alchemy.setElementDirty $(this).closest(".element-editor")
        $(this).datetimepicker(options)

    return
