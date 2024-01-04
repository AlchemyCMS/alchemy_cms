export default function (func, delay) {
  let timeout

  return function (...args) {
    const that = this

    clearTimeout(timeout)
    timeout = setTimeout(() => func.apply(that, args), delay)
  }
}
