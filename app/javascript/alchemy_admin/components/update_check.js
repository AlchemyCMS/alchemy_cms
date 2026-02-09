import Spinner from "alchemy_admin/spinner"

class UpdateCheck extends HTMLElement {
  async connectedCallback() {
    const spinner = new Spinner("small")
    spinner.spin(this)

    try {
      const response = await fetch(this.url, { credentials: "include" })
      const responseJSON = await response.json()

      if (response.ok) {
        this.showStatus(responseJSON)
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

  showStatus(responseJSON) {
    if (responseJSON["status"] == "true") {
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
