window.Alchemy = {} if typeof(window.Alchemy) is 'undefined'

Alchemy.Buttons =

  observe: (scope) ->
    $('form', scope).not('.button_with_label form').on 'submit', (event) ->
      $form = $(this)
      $btn = $form.find(':submit')
      $outside_button = $('[data-alchemy-button][form="'+$form.attr('id')+'"]')

      if ($btn.attr('disabled') == 'disabled') || ($outside_button.attr('disabled') == 'disabled')
        event.preventDefault()
        event.stopPropagation()
        false
      else
        Alchemy.Buttons.disable($btn)
        if $outside_button
          Alchemy.Buttons.disable($outside_button)
        true

  disable: (button) ->
    $button = $(button)
    spinner = new Alchemy.Spinner('small')
    $button.data('content', $button.html())
    $button.attr('disabled', true)
    $button.attr('tabindex', '-1')
    $button.addClass('disabled')
    $button.css
      width: $button.outerWidth()
      height: $button.outerHeight()
    $button.empty()
    spinner.spin($button)
    return true

  enable: (scope) ->
    $buttons = $('form :submit:disabled, [data-alchemy-button].disabled', scope)
    $.each $buttons, ->
      $button = $(this)
      $button.removeClass('disabled')
      $button.removeAttr('disabled')
      $button.removeAttr('tabindex')
      $button.css("width", "")
      $button.css("height", "")
      $button.html($button.data('content'))
    return true
