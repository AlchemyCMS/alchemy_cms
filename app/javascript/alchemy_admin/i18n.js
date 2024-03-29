import { en } from "alchemy_admin/locales/en"

Alchemy.translations = Object.assign(Alchemy.translations || {}, { en })

const KEY_SEPARATOR = /\./

function getTranslations() {
  const locale = currentLocale()
  const translations = Alchemy.translations && Alchemy.translations[locale]

  if (translations) {
    return translations
  }
  console.warn(`Translations for locale ${locale} not found!`)
  return {}
}

function nestedTranslation(translations, key) {
  const keys = key.split(KEY_SEPARATOR)
  const group = translations[keys[0]]
  if (group) {
    return group[keys[1]] || key
  }
  return key
}

function getTranslation(key) {
  const translations = getTranslations()

  if (KEY_SEPARATOR.test(key)) {
    return nestedTranslation(translations, key)
  }
  return translations[key] || key
}

export function currentLocale() {
  if (document.documentElement.lang) {
    return document.documentElement.lang
  }
  return "en"
}

export function translate(key, replacement = undefined) {
  let translation = getTranslation(key)

  if (replacement) {
    return translation.replace(/%\{.+\}/, replacement)
  }
  return translation
}
