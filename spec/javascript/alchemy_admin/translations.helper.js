// Run this before all tests that needs translations available
export const setupTranslations = () => {
  window.Alchemy.translations = {
    allowed_chars: "of %{count} chars",
    help: "Help",
    formats: {
      date: "Y-m-d"
    }
  }
}
