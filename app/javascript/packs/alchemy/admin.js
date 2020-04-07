import translate from "alchemy/admin/i18n"

// Global Alchemy object
if (typeof window.Alchemy === "undefined") {
  window.Alchemy = {}
}

// Global utility method for translating a given string
//
Alchemy.t = (key, replacement) => {
  return translate(key, replacement)
}
