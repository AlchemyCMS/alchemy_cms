window.Alchemy = {} if typeof(window.Alchemy) is 'undefined'

$.extend Alchemy,

  Datepicker: (scope) ->
    browserHasDatepicker = Alchemy.isiOS
    datepicker_options =
      dateFormat: "yy-mm-dd"
      changeMonth: true
      changeYear: true
      showWeek: true
      showButtonPanel: true
      showOtherMonths: true
      onSelect: ->
        Alchemy.setElementDirty $(this).parents("div.element_editor")

    if Alchemy.locale is "de"
      $.extend datepicker_options,
        dateFormat: "dd.mm.yy"
        dayNames: ["Sonntag", "Montag", "Dienstag", "Mittwoch", "Donnerstag", "Freitag", "Samstag"]
        dayNamesMin: ["So", "Mo", "Di", "Mi", "Do", "Fr", "Sa"]
        monthNames: ["Januar", "Februar", "März", "April", "Mai", "Juni", "Juli", "August", "September", "Oktober", "November", "Dezember"]
        monthNamesShort: ["Jan", "Feb", "Mär", "Apr", "Mai", "Jun", "Jul", "Aug", "Sep", "Okt", "Nov", "Dez"]
        closeText: "Ok"
        currentText: "Heute"
        weekHeader: "KW"
        nextText: "nächster"
        prevText: "vorheriger"

    # Initializes the jQueryUI datepicker and disables the browsers default Datepicker unless the browser is iOS.
    $('input[type="date"], input.date', scope).datepicker(datepicker_options).prop "type", "text" unless browserHasDatepicker
