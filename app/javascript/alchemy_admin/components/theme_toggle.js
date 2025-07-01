class ThemeToggle extends HTMLElement {
  constructor() {
    super()

    this.detectColorScheme()
    this.slSelect.addEventListener("sl-change", this)
  }

  async handleEvent(event) {
    switch (event.target.value) {
      case "dark":
        await this.setDarkMode()
        localStorage.setItem("alchemy-theme", "dark")
        break
      case "light":
        await this.setLightMode()
        localStorage.setItem("alchemy-theme", "light")
        break
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
      this.slSelect.setAttribute("value", "dark")
      this.icon.setAttribute("name", "moon")
      resolve()
    })
  }

  setLightMode() {
    return new Promise((resolve) => {
      document.documentElement.classList.add("alchemy-light")
      document.documentElement.classList.remove("alchemy-dark")
      this.slSelect.setAttribute("value", "light")
      this.icon.setAttribute("name", "sun")
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

  get slSelect() {
    return this.querySelector("sl-select")
  }

  get icon() {
    return this.querySelector("alchemy-icon")
  }
}

customElements.define("alchemy-theme-toggle", ThemeToggle)
