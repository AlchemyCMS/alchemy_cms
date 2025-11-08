import { registerIconLibrary } from "webawesome"

// Change the default animation for all tooltips
// setDefaultAnimation("tooltip.show", {
//   keyframes: [
//     { transform: "translateY(10px)", opacity: "0" },
//     { transform: "translateY(0)", opacity: "1" }
//   ],
//   options: {
//     duration: 100
//   }
// })

// setDefaultAnimation("tooltip.hide", {
//   keyframes: [
//     { transform: "translateY(0)", opacity: "1" },
//     { transform: "translateY(10px)", opacity: "0" }
//   ],
//   options: {
//     duration: 100
//   }
// })

// // Change the default animation for all dialogs
// setDefaultAnimation("dialog.show", {
//   keyframes: [
//     { transform: "scale(0.98)", opacity: "0" },
//     { transform: "scale(1)", opacity: "1" }
//   ],
//   options: {
//     duration: 150
//   }
// })

// setDefaultAnimation("dialog.hide", {
//   keyframes: [
//     { transform: "scale(1)", opacity: "1" },
//     { transform: "scale(0.98)", opacity: "0" }
//   ],
//   options: {
//     duration: 150
//   }
// })

const spriteUrl = document
  .querySelector('link[rel="preload"][as="image"]')
  .getAttribute("href")

const iconMap = {
  "x-lg": "close"
}

const options = {
  resolver: (name) => `${spriteUrl}#ri-${iconMap[name] || name}-line`,
  mutator: (svg) => svg.setAttribute("fill", "currentColor"),
  spriteSheet: true
}

registerIconLibrary("default", options)
registerIconLibrary("system", options)
