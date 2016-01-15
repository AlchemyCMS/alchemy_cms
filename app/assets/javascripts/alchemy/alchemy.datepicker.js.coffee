window.Alchemy = {} if typeof(window.Alchemy) is 'undefined'

$.extend Alchemy,

  Datepicker: (scope) ->
    options =
      format: "Y/m/d H:i"
      formatDate: "Y/m/d"
      formatTime: "H:i"
      onSelectDate: ->
        Alchemy.setElementDirty $(this).closest(".element-editor")

    if Alchemy.locale is "de"
      $.extend options,
        format: "d.m.Y H:i"
        formatDate: "d.m.Y"
        dayOfWeekStart: 1

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
