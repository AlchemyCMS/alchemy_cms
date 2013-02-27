window.Alchemy = {} if typeof(window.Alchemy) is 'undefined'

Alchemy.Spinner =

  DEFAULTS:
    lines: 5
    corners: 0.75
    rotate: 54
    trail: 75
    speed: 1.25
    hwaccel: true

  small: (opts) ->
    defaults = $.extend({}, Alchemy.Spinner.DEFAULTS,
      length: 2
      width: 3
      radius: 2
    )
    new Spinner($.extend(defaults, opts))

  medium: (opts) ->
    defaults = $.extend({}, Alchemy.Spinner.DEFAULTS,
      length: 4
      width: 6
      radius: 4
    )
    new Spinner($.extend(defaults, opts))

  large: (opts) ->
    defaults = $.extend({}, Alchemy.Spinner.DEFAULTS,
      length: 8
      width: 12
      radius: 8
    )
    new Spinner($.extend(defaults, opts))
