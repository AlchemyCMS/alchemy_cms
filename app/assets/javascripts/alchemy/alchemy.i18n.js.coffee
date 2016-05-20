#= require alchemy/alchemy.translations

window.Alchemy = {} if typeof(window.Alchemy) is 'undefined'

Alchemy.I18n =

  KEY_SEPARATOR: /\./

  # Translates given string
  #
  translate: (key, replacement) ->
    if !Alchemy.locale?
      throw 'Alchemy.locale is not set! Please set Alchemy.locale to a locale string in order to translate something.'
    translations = Alchemy.translations[Alchemy.locale]
    if translations
      if @KEY_SEPARATOR.test(key)
        keys = key.split(@KEY_SEPARATOR)
        translation = translations[keys[0]][keys[1]] || key
      else
        translation = translations[key] || key
      if replacement
        translation.replace(/%\{.+\}/, replacement)
      else
        translation
    else
      Alchemy.debug "Translations for locale #{Alchemy.locale} not found!"
      key

# Global utility method for translating a given string
#
Alchemy.t = (key, replacement) ->
  Alchemy.I18n.translate(key, replacement)
