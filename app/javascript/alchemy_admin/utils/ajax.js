const JSON_CONTENT_TYPE = "application/json"

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

export function patch(url, data) {
  return ajax("PATCH", url, data)
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
  const responseData = isJson ? await response.json() : null

  if (response.ok) {
    return { data: responseData, status: response.status }
  } else {
    throw responseData || new Error("An error occurred during the transaction")
  }
}
