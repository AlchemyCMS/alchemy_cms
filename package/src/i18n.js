const KEY_SEPARATOR = /\./

function currentLocale() {
  if (Alchemy.locale == null) {
    throw "Alchemy.locale is not set! Please set Alchemy.locale to a locale string in order to translate something."
  }
  return Alchemy.locale
}

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

export default function translate(key, replacement) {
  let translation = getTranslation(key)

  if (replacement) {
    return translation.replace(/%\{.+\}/, replacement)
  }
  return translation
}
