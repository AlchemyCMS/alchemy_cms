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

Alchemy.xhr = function(method, url) {
  var xhr = new XMLHttpRequest()
  var token = document.querySelector('meta[name="csrf-token"]').attributes.content.textContent
  xhr.open(method, url);
  xhr.setRequestHeader('Content-type', 'application/json; charset=utf-8');
  xhr.setRequestHeader('X-CSRF-Token', token)

  return xhr;
}
