window.Alchemy = {} if typeof(window.Alchemy) is 'undefined'

Alchemy.Buttons =

  observe: (scope) ->
    $('form', scope).not('.button_with_label form').on 'submit', (event) ->
      $btn = $(this).find(':submit')
      if $btn.attr('disabled') == 'disabled'
        event.preventDefault()
        event.stopPropagation()
        false
      else
        Alchemy.Buttons.disable($btn)

  disable: (button) ->
    $button = $(button)
    spinner = Alchemy.Spinner.small()
    $button.data('content', $button.html())
    $button.attr('disabled', true)
    $button.addClass('disabled')
    $button.css
      width: $button.outerWidth()
    $button.empty()
    spinner.spin($button[0])
    return true

  enable: (scope) ->
    $button = $('form :submit:disabled', scope)
    $button.removeClass('disabled')
    $button.removeAttr('disabled')
    $button.html($button.data('content'))
    return true
