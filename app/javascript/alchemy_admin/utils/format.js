export function formatFileSize(bytes) {
  let exponent = bytes === 0 ? 0 : Math.floor(Math.log(bytes) / Math.log(1024))

  // prevent format higher than GB
  if (exponent > 3) {
    exponent = 3
  }

  let value = (bytes / Math.pow(1024, exponent)).toFixed(2)
  return value + " " + ["B", "kB", "MB", "GB"][exponent]
}
