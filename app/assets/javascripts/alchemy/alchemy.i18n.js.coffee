#= require alchemy/alchemy.translations

window.Alchemy = {} if typeof(window.Alchemy) is 'undefined'

Alchemy.I18n =

  # Translates given string
  #
  translate: (key, replacement) ->
    if !Alchemy.locale?
      throw 'Alchemy.locale is not set! Please set Alchemy.locale to a locale string in order to translate something.'
    translations = Alchemy.translations[Alchemy.locale]
    if translations
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
Alchemy._t = (key, replacement) ->
  Alchemy.I18n.translate(key, replacement)
