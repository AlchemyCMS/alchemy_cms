Alchemy.on = function (eventName, baseSelector, targetSelector, callback) {
  var baseNode = document.querySelector(baseSelector)
  baseNode.addEventListener(eventName, function (evt) {
    var targets = Array.from(baseNode.querySelectorAll(targetSelector))
    var currentNode = evt.target
    while (currentNode !== baseNode) {
      if (targets.includes(currentNode)) {
        callback.call(currentNode, evt)
        return
      }
      currentNode = currentNode.parentElement
    }
  });
}
