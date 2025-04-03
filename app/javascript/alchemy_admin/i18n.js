const KEY_SEPARATOR = /\./

function nestedTranslation(translations, key) {
  const keys = key.split(KEY_SEPARATOR)
  const group = translations[keys[0]]
  if (group) {
    return group[keys[1]] || key
  }
  return key
}

function getTranslation(key) {
  const locale = currentLocale()
  const translations = Alchemy.translations

  if (!translations) {
    console.warn(`Translations for locale ${locale} not found!`)
    return key
  }

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

export async function setupSelectLocale() {
  const locale = currentLocale()
  if (locale === "en") return

  await import(`select2/${locale}.js`)
  $.extend($.fn.select2.defaults, $.fn.select2.locales[locale])
}
