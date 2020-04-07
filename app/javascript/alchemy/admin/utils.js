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

export function ajax(method, url, data) {
  const xhr = new XMLHttpRequest()
  const token = document.querySelector('meta[name="csrf-token"]').attributes
    .content.textContent
  const promise = new Promise((resolve, reject) => {
    xhr.onload = () => {
      try {
        resolve({
          data: JSON.parse(xhr.responseText),
          status: xhr.status
        })
      } catch (error) {
        reject(new Error(JSON.parse(xhr.responseText).error))
      }
    }
    xhr.onerror = () => {
      reject(new Error(xhr.statusText))
    }
  })
  xhr.open(method, url)
  xhr.setRequestHeader("Content-type", "application/json; charset=utf-8")
  xhr.setRequestHeader("Accept", "application/json")
  xhr.setRequestHeader("X-CSRF-Token", token)
  if (data) {
    xhr.send(JSON.stringify(data))
  } else {
    xhr.send()
  }
  return promise
}
