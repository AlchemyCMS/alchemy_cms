export function dispatchPageDirtyEvent(data) {
  document.dispatchEvent(
    new CustomEvent("alchemy:page-dirty", {
      detail: { tooltip: data.publishButtonTooltip }
    })
  )
}
