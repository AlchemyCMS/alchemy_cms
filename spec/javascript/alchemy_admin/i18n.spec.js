import { vi } from "vitest"
import {
  translate,
  currentLocale
} from "../../../app/javascript/alchemy_admin/i18n.js"

describe("i18n", () => {
  describe("currentLocale", () => {
    afterEach(() => {
      document.documentElement.lang = ""
      vi.clearAllMocks()
    })

    it("should return 'en' as result, if nothing is set", () => {
      expect(currentLocale()).toEqual("en")
    })

    it("should return the language of the document", () => {
      document.documentElement.lang = "it"
      expect(currentLocale()).toEqual("it")
    })
  })

  describe("translate", () => {
    afterEach(() => {
      vi.clearAllMocks()
    })

    describe("if lang is set to a known locale", () => {
      beforeEach(() => {
        document.documentElement.lang = "en"
      })

      describe("if translation is present", () => {
        it("Returns translated string", () => {
          expect(translate("help")).toEqual("Help")
        })

        describe("if key includes a period", () => {
          describe("that is translated", () => {
            it("splits into group", () => {
              expect(translate("formats.date")).toEqual("Y-m-d")
            })
          })

          describe("that is not translated", () => {
            it("returns key", () => {
              expect(translate("formats.lala")).toEqual("formats.lala")
            })
          })

          describe("that has unknown group", () => {
            it("returns key", () => {
              expect(translate("foo.bar")).toEqual("foo.bar")
            })
          })
        })

        describe("if replacement is given", () => {
          it("replaces it", () => {
            expect(translate("allowed_chars", 5)).toEqual("of 5 chars")
          })
        })
      })

      describe("if translation is not present", () => {
        it("Returns passed string", () => {
          expect(translate("foo")).toEqual("foo")
        })
      })
    })

    describe("without a translations script tag", () => {
      let script

      beforeEach(() => {
        script = document.getElementById("alchemy_translations")
        script.remove()
        vi.resetModules()
      })

      afterEach(() => {
        document.head.appendChild(script)
      })

      it("Returns passed string and logs a warning", async () => {
        const { translate } = await import("alchemy_admin/i18n")
        const spy = vi.spyOn(console, "warn").mockImplementation(() => {})
        expect(translate("help")).toEqual("help")
        expect(spy.mock.calls).toEqual([
          ["Translations for locale en not found!"]
        ])
        spy.mockRestore()
      })
    })

    describe("if there is no global Alchemy object", () => {
      let alchemy

      beforeEach(() => {
        alchemy = globalThis.Alchemy
        delete globalThis.Alchemy
      })

      afterEach(() => {
        globalThis.Alchemy = alchemy
      })

      it("translates the given key", () => {
        expect(translate("help")).toEqual("Help")
      })
    })
  })
})
