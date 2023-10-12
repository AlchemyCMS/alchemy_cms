import "@shoelace/alert"
import { registerIconLibrary } from "@shoelace/icon-library"

registerIconLibrary("default", {
  resolver: (name) =>
    `https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/icons/${name}.svg`
})

function notify(
  message,
  variant = "primary",
  icon = "info-circle-fill",
  duration = 3000
) {
  const alert = Object.assign(document.createElement("sl-alert"), {
    variant,
    closable: true,
    innerHTML: `
      <sl-icon name="${icon}" slot="icon"></sl-icon>
      ${message}
    `
  })
  if (variant !== "danger") {
    alert.duration = duration
  }
  document.body.append(alert)
  alert.toast()
}

function messageIcon(messageType) {
  switch (messageType) {
    case "alert":
    case "warn":
    case "warning":
      return "exclamation-triangle-fill"
    case "notice":
      return "check-lg"
    case "error":
      return "bug-fill"
    default:
      return "info-circle-fill"
  }
}

function messageStyle(messageType) {
  switch (messageType) {
    case "alert":
    case "warn":
    case "warning":
      return "warning"
    case "notice":
    case "success":
      return "success"
    case "danger":
    case "error":
      return "danger"
    case "info":
      return "primary"
    default:
      return "neutral"
  }
}

export default function (message, style = "notice") {
  notify(message, messageStyle(style), messageIcon(style))
}
