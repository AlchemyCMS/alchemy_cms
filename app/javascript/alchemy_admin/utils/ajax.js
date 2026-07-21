const JSON_CONTENT_TYPE = "application/json"
const TURBO_STREAM_CONTENT_TYPE = "text/vnd.turbo-stream.html"

function isGetRequest(method) {
  return method.toLowerCase() === "get"
}

function prepareURL(path, data, method) {
  const url = new URL(window.location.origin + path)

  if (data && isGetRequest(method)) {
    url.search = new URLSearchParams(data).toString()
  }

  return url.toString()
}

function prepareHeaders(accept) {
  return {
    "Content-Type": "application/json; charset=utf-8",
    Accept: accept,
    "X-Requested-With": "XMLHttpRequest",
    "X-CSRF-Token": getToken()
  }
}

function prepareOptions(method, data, accept) {
  const headers = prepareHeaders(accept)
  const options = { method, headers }

  if (data && !isGetRequest(method)) {
    options.body = JSON.stringify(data)
  }

  return options
}

export function getToken() {
  const metaTag = document.querySelector('meta[name="csrf-token"]')
  return metaTag.attributes.content.textContent
}

export function get(url, params) {
  return ajax("GET", url, params)
}

export function patch(url, data, accept) {
  return ajax("PATCH", url, data, accept)
}

export function post(url, data, accept = JSON_CONTENT_TYPE) {
  return ajax("POST", url, data, accept)
}

export default async function ajax(
  method,
  path,
  data,
  accept = JSON_CONTENT_TYPE
) {
  const response = await fetch(
    prepareURL(path, data, method),
    prepareOptions(method, data, accept)
  )
  const contentType = response.headers.get("content-type")
  const isJson = contentType?.includes(JSON_CONTENT_TYPE)
  const isTurboStream = contentType?.includes(TURBO_STREAM_CONTENT_TYPE)

  let responseData = null
  if (isJson) {
    responseData = await response.json()
  } else if (isTurboStream) {
    responseData = await response.text()
    // Automatically render Turbo Stream if Turbo is available
    if (typeof Turbo !== "undefined") {
      Turbo.renderStreamMessage(responseData)
    }
  }

  if (response.ok) {
    return { data: responseData, status: response.status }
  }

  // The session expired while the tab was open. Send the user to the login
  // page instead of leaving them with an error they cannot act on. Never
  // settle, so callers skip their error handling: the login page is what the
  // user needs to see, not a growl about a request they cannot retry.
  if (response.status === 401 && responseData?.redirect_url) {
    Turbo.visit(responseData.redirect_url)
    return new Promise(() => {})
  }

  throw responseData || new Error("An error occurred during the transaction")
}
