import { AlchemyHTMLElement } from "./alchemy_html_element"
import { translate, currentLocale } from "alchemy_admin/i18n"
import flatpickr from "flatpickr"

class Datepicker extends AlchemyHTMLElement {
  static properties = {
    inputType: { default: "date" }
  }

  constructor() {
    super()
    this.flatpickr = undefined
  }

  afterRender() {
    const options = {
      // alchemy_i18n supports `zh_CN` etc., but flatpickr only has two-letter codes (`zh`)
      locale: currentLocale().slice(0, 2),
      altInput: true,
      altFormat: translate(`formats.${this.inputType}`),
      altInputClass: "flatpickr-input",
      dateFormat: "Z",
      enableTime: /time/.test(this.inputType),
      noCalendar: this.inputType === "time",
      time_24hr: translate("formats.time_24hr"),
      onValueUpdate(_selectedDates, _dateStr, instance) {
        instance.element.closest("alchemy-element-editor").setDirty()
      }
    }

    this.flatpickr = flatpickr(this.getElementsByTagName("input")[0], options)
  }

  disconnected() {
    this.flatpickr.destroy()
  }
}

customElements.define("alchemy-datepicker", Datepicker)
