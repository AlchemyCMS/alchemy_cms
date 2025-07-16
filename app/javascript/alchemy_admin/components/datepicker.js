import { AlchemyHTMLElement } from "alchemy_admin/components/alchemy_html_element"
import { translate, currentLocale } from "alchemy_admin/i18n"
import flatpickr from "flatpickr"

const locale = currentLocale()

class Datepicker extends AlchemyHTMLElement {
  static properties = {
    inputType: { default: "date" }
  }

  constructor() {
    super()
    this.flatpickr = undefined
  }

  // Load the locales for flatpickr before setting it up.
  async connected() {
    // English is the default locale for flatpickr, so we don't need to load it
    if (locale !== "en") {
      await import(`flatpickr/${locale}.js`)
    }

    this.flatpickr = flatpickr(this.inputField, this.flatpickrOptions)
  }

  disconnected() {
    this.flatpickr.destroy()
  }

  get flatpickrOptions() {
    const enableTime = /time/.test(this.inputType)
    const options = {
      // alchemy_i18n supports `zh_CN` etc., but flatpickr only has two-letter codes (`zh`)
      locale: locale.slice(0, 2),
      altInput: true,
      altFormat: translate(`formats.${this.inputType}`),
      altInputClass: "flatpickr-input",
      enableTime,
      noCalendar: this.inputType === "time",
      time_24hr: translate("formats.time_24hr"),
      onValueUpdate(_selectedDates, _dateStr, instance) {
        instance.element
          .closest("alchemy-element-editor")
          ?.setDirty(this.inputField)
      }
    }

    if (enableTime) {
      options.dateFormat = "Z"
    }

    return options
  }

  get inputField() {
    return this.querySelector("input")
  }
}

customElements.define("alchemy-datepicker", Datepicker)
