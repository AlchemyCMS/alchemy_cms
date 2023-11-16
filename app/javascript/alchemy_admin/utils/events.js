export function on(eventName, baseSelector, targetSelector, callback) {
  document.querySelectorAll(baseSelector).forEach((baseNode) => {
    const targets = Array.from(baseNode.querySelectorAll(targetSelector))

    baseNode.addEventListener(eventName, (evt) => {
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
