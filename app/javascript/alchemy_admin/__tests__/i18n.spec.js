import translate from "../i18n"

describe("translate", () => {
  describe("if Alchemy.locale is not set", () => {
    it("Throws an error", () => {
      expect(() => {
        translate("help")
      }).toThrow("Alchemy.locale is not set")
    })
  })

  describe("if Alchemy.locale is set to a known locale", () => {
    beforeEach(() => {
      Alchemy.locale = "en"
    })

    describe("if translation is present", () => {
      beforeEach(() => {
        Alchemy.translations = { en: { help: "Help" } }
      })

      it("Returns translated string", () => {
        expect(translate("help")).toEqual("Help")
      })

      describe("if key includes a period", () => {
        describe("that is translated", () => {
          beforeEach(() => {
            Alchemy.translations = { en: { formats: { date: "Y-m-d" } } }
          })

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
        beforeEach(() => {
          Alchemy.translations = { en: { allowed_chars: "of %{number} chars" } }
        })

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

  describe("if Alchemy.locale is set to a unknown locale", () => {
    beforeEach(() => {
      Alchemy.locale = "kl"
    })

    it("Returns passed string and logs a warning", () => {
      const spy = jest.spyOn(console, "warn").mockImplementation(() => {})
      expect(translate("help")).toEqual("help")
      expect(spy.mock.calls).toEqual([
        ["Translations for locale kl not found!"]
      ])
      spy.mockRestore()
    })
  })

  describe("if Alchemy.translations is not set", () => {
    it("Returns passed string and logs a warning", () => {
      const spy = jest.spyOn(console, "warn").mockImplementation(() => {})
      expect(translate("help")).toEqual("help")
      expect(spy.mock.calls).toEqual([
        ["Translations for locale kl not found!"]
      ])
      spy.mockRestore()
    })
  })
})
