module I18n
  module_function
  # this is not chainable, since FastGettext may reject this locale!
  def locale=(new_locale)
    FastGettext.locale = new_locale
  end
  def locale
    FastGettext.locale.to_sym
  end
end