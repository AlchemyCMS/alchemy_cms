window.Alchemy = {} if typeof(window.Alchemy) is 'undefined'

$.extend Alchemy,

  Datepicker: (scope) ->
    options =
      format: Alchemy.t('formats.datetime')
      formatDate: Alchemy.t('formats.date')
      formatTime: Alchemy.t('formats.time')
      dayOfWeekStart: Alchemy.t('formats.start_of_week')
      onSelectDate: ->
        Alchemy.setElementDirty $(this).closest(".element-editor")

    datepicker_options = $.extend {}, options,
      format: options.formatDate
      timepicker: false

    timepicker_options = $.extend {}, options,
      format: options.formatTime
      datepicker: false

    $.datetimepicker.setLocale(Alchemy.locale);

    # Initializes the datepickers and disables the browsers default Datepicker
    # unless the browser is iOS.
    $('input[type="date"], input.date', scope)
      .datetimepicker(datepicker_options).prop "type", "text" unless Alchemy.isiOS

    $('input[type="time"], input.time', scope)
      .datetimepicker(timepicker_options).prop "type", "text" unless Alchemy.isiOS

    $('input[type="datetime"], input.datetime', scope)
      .datetimepicker(options).prop "type", "text" unless Alchemy.isiOS

    return
