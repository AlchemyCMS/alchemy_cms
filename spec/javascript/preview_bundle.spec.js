import { afterEach, beforeEach, describe, expect, it } from "vitest"
import { readFileSync } from "node:fs"
import path from "node:path"
import { JSDOM } from "jsdom"

// Rails includes the built bundle as a classic script, so anything it declares
// at the top level would share the global scope with the host page's scripts.
const bundle = readFileSync(
  path.resolve(
    import.meta.dirname,
    "../../app/assets/builds/alchemy/preview.min.js"
  ),
  "utf8"
)

describe("preview bundle", () => {
  let window

  function runScript(code) {
    const script = window.document.createElement("script")
    script.textContent = code
    window.document.body.append(script)
  }

  beforeEach(() => {
    window = new JSDOM("<!DOCTYPE html><body></body>", {
      url: "http://localhost/",
      runScripts: "dangerously"
    }).window
  })

  afterEach(() => {
    window.close()
  })

  it("does not add globals to window", () => {
    const globals = Object.getOwnPropertyNames(window)

    runScript(bundle)

    const added = Object.getOwnPropertyNames(window).filter(
      (name) => !globals.includes(name)
    )
    expect(added).toEqual([])
  })

  it("does not clash with top level declarations of the host page", () => {
    const errors = []
    window.addEventListener("error", (event) => errors.push(event.error))

    runScript(bundle)
    runScript("const e = 1")

    expect(errors).toEqual([])
  })
})
