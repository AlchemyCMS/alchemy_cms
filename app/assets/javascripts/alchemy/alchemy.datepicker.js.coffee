window.Alchemy = {} if typeof(window.Alchemy) is 'undefined'

$.extend Alchemy,

  Datepicker: (scope) ->
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
          # alchemy_i18n supports `zh_CN` etc., but flatpickr only has two-letter codes (`zh`)
          locale: Alchemy.locale.slice(0, 2)
          altInput: true
          altFormat: Alchemy.t("formats.#{type}")
          altInputClass: ""
          enableTime: /time/.test(type)
          noCalendar: type == "time"
          time_24hr: Alchemy.t("formats.time_24hr")
          onValueUpdate: (_selectedDates, _dateStr, instance) ->
            Alchemy.setElementDirty $(instance.element).closest(".element-editor")
        $(this).flatpickr(options)

    return
