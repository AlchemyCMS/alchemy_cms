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

function getToken() {
  const metaTag = document.querySelector('meta[name="csrf-token"]')
  return metaTag.attributes.content.textContent
}

export default function ajax(method, url, data) {
  const xhr = new XMLHttpRequest()
  const promise = buildPromise(xhr)

  xhr.open(method, url)
  xhr.setRequestHeader("Content-type", "application/json; charset=utf-8")
  xhr.setRequestHeader("Accept", "application/json")
  xhr.setRequestHeader("X-CSRF-Token", getToken())

  if (data) {
    xhr.send(JSON.stringify(data))
  } else {
    xhr.send()
  }

  return promise
}
