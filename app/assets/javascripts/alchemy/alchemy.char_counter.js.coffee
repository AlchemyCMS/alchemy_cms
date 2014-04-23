class window.Alchemy.CharCounter

  constructor: (field) ->
    @$field = $(field)
    @max_chars = @$field.data('alchemy-char-counter')
    @text = Alchemy._t('allowed_chars', @max_chars)
    @$display = $('<small class="alchemy-char-counter"/>')
    @$field.after(@$display)
    countChars.call(this)
    @$field.keyup =>
      countChars.call(this)
      true

  countChars = ->
    char_length = @$field.val().length
    @$display.removeClass('too-long')
    @$display.text("#{char_length} #{@text}")
    if char_length > @max_chars
      @$display.addClass('too-long')
