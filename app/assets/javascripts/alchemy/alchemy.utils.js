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

Alchemy.ajax = function(method, url, data) {
  var xhr = new XMLHttpRequest()
  var token = document.querySelector('meta[name="csrf-token"]').attributes.content.textContent
  var promise = new Promise(function (resolve, reject) {
    xhr.onload = function() {
      try {
        resolve({
          data: JSON.parse(xhr.responseText),
          status: xhr.status
        })
      } catch (error) {
        reject(new Error(JSON.parse(xhr.responseText).error))
      }
    };
    xhr.onerror = function() {
      reject(new Error(xhr.statusText))
    }
  });
  xhr.open(method, url);
  xhr.setRequestHeader('Content-type', 'application/json; charset=utf-8');
  xhr.setRequestHeader('Accept', 'application/json');
  xhr.setRequestHeader('X-CSRF-Token', token)
  if (data) {
    xhr.send(JSON.stringify(data))
  } else {
    xhr.send()
  }

  return promise
}
