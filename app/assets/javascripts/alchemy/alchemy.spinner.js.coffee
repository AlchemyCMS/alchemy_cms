window.Alchemy = {} if typeof(window.Alchemy) is 'undefined'

Alchemy.Spinner =

  DEFAULTS:
    lines: 5
    corners: 1
    rotate: 54
    trail: 75
    speed: 1.25
    hwaccel: true

  tiny: (opts) ->
    defaults = $.extend({}, Alchemy.Spinner.DEFAULTS,
      length: 2
      width: 1
      radius: 1
    )
    new Spinner($.extend(defaults, opts))

  small: (opts) ->
    defaults = $.extend({}, Alchemy.Spinner.DEFAULTS,
      length: 2
      width: 2
      radius: 2
    )
    new Spinner($.extend(defaults, opts))

  medium: (opts) ->
    defaults = $.extend({}, Alchemy.Spinner.DEFAULTS,
      length: 4
      width: 4
      radius: 4
    )
    new Spinner($.extend(defaults, opts))

  large: (opts) ->
    defaults = $.extend({}, Alchemy.Spinner.DEFAULTS,
      length: 8
      width: 10
      radius: 8
    )
    new Spinner($.extend(defaults, opts))

  watch: (scope) ->
    $('a.spinner', scope).click ->
      spinner = Alchemy.Spinner.tiny()
      spinner.spin(this)
      $(this).css('background': 'none').off('click')
