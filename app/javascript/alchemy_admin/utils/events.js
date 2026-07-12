// Dispatches a bubbling CustomEvent from the given element.
export function dispatchCustomEvent(element, name, detail = {}) {
  element.dispatchEvent(new CustomEvent(name, { bubbles: true, detail }))
}

export function on(eventName, baseSelector, targetSelector, callback) {
  document.querySelectorAll(baseSelector).forEach((baseNode) => {
    baseNode.addEventListener(eventName, (evt) => {
      const targets = Array.from(baseNode.querySelectorAll(targetSelector))
      let currentNode = evt.target

      while (currentNode !== baseNode) {
        if (targets.includes(currentNode)) {
          callback.call(currentNode, evt)
          return
        }
        currentNode = currentNode.parentElement
      }
    })
  })
}
