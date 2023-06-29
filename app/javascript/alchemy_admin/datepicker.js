import flatpickr from "flatpickr"

export default function Datepicker(scope = document) {
  if (scope === "") {
    scope = document
  } else if (scope instanceof String) {
    scope = document.querySelectorAll(scope)
  }

  const datepickerInputs = scope.querySelectorAll("input[data-datepicker-type]")

  // Initializes the datepickers on the text inputs and sets the proper type
  // to enable browsers default datepicker if the current OS is iOS.
  if (Alchemy.isiOS) {
    datepickerInputs.forEach((input) => {
      input.attributes.type = input.dataset.datepickerType
    })
  } else {
    datepickerInputs.forEach((input) => {
      const type = input.dataset.datepickerType
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
          return Alchemy.setElementDirty(
            instance.element.closest(".element-editor")
          )
        }
      }
      flatpickr(input, options)
    })
  }
}
