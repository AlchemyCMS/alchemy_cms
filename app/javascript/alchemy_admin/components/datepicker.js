import flatpickr from "flatpickr"

class Datepicker extends HTMLInputElement {
  constructor() {
    super()

    const type = this.dataset.datepickerType
    const options = {
      // alchemy_i18n supports `zh_CN` etc., but flatpickr only has two-letter codes (`zh`)
      locale: Alchemy.locale.slice(0, 2),
      altInput: true,
      altFormat: Alchemy.t(`formats.${type}`),
      altInputClass: "flatpickr-input",
      dateFormat: "Z",
      enableTime: /time/.test(type),
      noCalendar: type === "time",
      time_24hr: Alchemy.t("formats.time_24hr"),
      onValueUpdate(_selectedDates, _dateStr, instance) {
        Alchemy.setElementDirty(instance.element.closest(".element-editor"))
      }
    }

    flatpickr(this, options)
  }
}

customElements.define("alchemy-datepicker", Datepicker, { extends: "input" })
