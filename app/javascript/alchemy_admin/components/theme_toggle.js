class ThemeToggle extends HTMLElement {
  constructor() {
    super()

    this.detectColorScheme()
    this.slSwitch.addEventListener("sl-change", this)
  }

  async handleEvent(event) {
    if (event.target.checked) {
      await this.setDarkMode()
      localStorage.setItem("alchemy-theme", "dark")
    } else {
      await this.setLightMode()
      localStorage.setItem("alchemy-theme", "light")
    }
    if (document.querySelector("alchemy-tinymce")) {
      window.location.reload()
    }
  }

  detectColorScheme() {
    switch (this.storedTheme) {
      case "dark":
        this.setDarkMode()
        break
      case "light":
        this.setLightMode()
        break
      default:
        this.setPreferedMode()
    }
  }

  setDarkMode() {
    return new Promise((resolve) => {
      document.documentElement.classList.add("alchemy-dark")
      document.documentElement.classList.remove("alchemy-light")
      this.slSwitch.checked = true
      resolve()
    })
  }

  setLightMode() {
    return new Promise((resolve) => {
      document.documentElement.classList.add("alchemy-light")
      document.documentElement.classList.remove("alchemy-dark")
      this.slSwitch.checked = false
      resolve()
    })
  }

  setPreferedMode() {
    console.log("Setting prefered mode")
    if (this.prefersDark) {
      console.log("to dark")
      this.setDarkMode()
    } else {
      console.log("to light")
      this.setLightMode()
    }
  }

  get prefersDark() {
    return window.matchMedia("(prefers-color-scheme: dark)").matches
  }

  get storedTheme() {
    return localStorage.getItem("alchemy-theme")
  }

  get slSwitch() {
    return this.querySelector("sl-switch")
  }
}

customElements.define("alchemy-theme-toggle", ThemeToggle)
