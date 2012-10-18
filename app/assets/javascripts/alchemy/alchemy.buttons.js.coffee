window.Alchemy = {} if window.Alchemy == undefined

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
    spinner = '<img src="/assets/alchemy/ajax_loader.gif" style="width: 16px; height: 16px">'
    $button.data('label', $button.text())
    $button.attr('disabled', true)
    $button.addClass('disabled')
    $button.css
      width: $button.outerWidth()
    $button.html(spinner)
    return true

  enable: (scope) ->
    $button = $('form :submit:disabled', scope)
    $button.removeClass('disabled')
    $button.removeAttr('disabled')
    $button.text($button.data('label'))
    return true
