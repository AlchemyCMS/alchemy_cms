function buildPromise(xhr) {
  return new Promise((resolve, reject) => {
    xhr.onload = () => {
      if (xhr.status >= 200 && xhr.status < 400) {
        try {
          resolve({
            data: JSON.parse(xhr.responseText),
            status: xhr.status
          })
        } catch (error) {
          reject(error)
        }
      } else {
        try {
          reject(JSON.parse(xhr.responseText))
        } catch (error) {
          reject(error)
        }
      }
    }
    xhr.onerror = () => {
      reject(new Error("An error occurred during the transaction"))
    }
  })
}

export function getToken() {
  const metaTag = document.querySelector('meta[name="csrf-token"]')
  return metaTag.attributes.content.textContent
}

export function get(url, params) {
  return ajax("GET", url, params)
}

export function patch(url, data) {
  return ajax("PATCH", url, data)
}

export function post(url, data, accept = "application/json") {
  return ajax("POST", url, data, accept)
}

export default function ajax(method, path, data, accept = "application/json") {
  const xhr = new XMLHttpRequest()
  const promise = buildPromise(xhr)
  const url = new URL(window.location.origin + path)

  if (data && method.toLowerCase() === "get") {
    url.search = new URLSearchParams(data).toString()
  }

  xhr.open(method, url.toString())
  xhr.setRequestHeader("Content-type", "application/json; charset=utf-8")
  xhr.setRequestHeader("Accept", accept)
  xhr.setRequestHeader("X-Requested-With", "XMLHttpRequest")
  xhr.setRequestHeader("X-CSRF-Token", getToken())

  if (data && method.toLowerCase() !== "get") {
    xhr.send(JSON.stringify(data))
  } else {
    xhr.send()
  }

  return promise
}
