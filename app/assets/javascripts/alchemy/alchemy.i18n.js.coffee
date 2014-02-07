#= require alchemy/alchemy.translations

window.Alchemy = {} if typeof(window.Alchemy) is 'undefined'

Alchemy.I18n =

  # Translates given string
  #
  translate: (id) ->
    if !Alchemy.locale?
      throw 'Alchemy.locale is not set! Please set Alchemy.locale to a locale string in order to translate something.'
    translation = Alchemy.translations[id]
    if (translation)
      translation[Alchemy.locale]
    else
      id

# Global utility method for translating a given string
#
Alchemy._t = (id) ->
  Alchemy.I18n.translate(id)
