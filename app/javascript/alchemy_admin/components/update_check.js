import Spinner from "alchemy_admin/spinner"

class UpdateCheck extends HTMLElement {
  async connectedCallback() {
    const spinner = new Spinner("small")
    spinner.spin(this)

    try {
      const response = await fetch(this.url)
      const responseText = await response.text()

      if (response.ok) {
        this.showStatus(responseText)
      } else {
        this.showError(response)
      }
    } catch (error) {
      this.showError(error)
    } finally {
      spinner.stop()
    }
  }

  get url() {
    return this.getAttribute("url")
  }

  showStatus(responseText) {
    if (responseText == "true") {
      this.querySelector(".update_available").classList.remove("hidden")
    } else {
      this.querySelector(".up_to_date").classList.remove("hidden")
    }
  }

  showError(error) {
    this.querySelector(".error").classList.remove("hidden")
    console.error("[alchemy] Error fetching update status", error)
  }
}

customElements.define("alchemy-update-check", UpdateCheck)
