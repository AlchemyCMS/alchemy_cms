import xhrMock from "xhr-mock"
import ajax from "../ajax"

const token = "s3cr3t"

beforeEach(() => {
  document.head.innerHTML = `<meta name="csrf-token" content="${token}">`
  xhrMock.setup()
})

describe("ajax('get')", () => {
  it("sends X-CSRF-TOKEN header", async () => {
    xhrMock.get("http://localhost/users", (req, res) => {
      expect(req.header("X-CSRF-TOKEN")).toEqual(token)
      return res.status(200).body('{"message":"Ok"}')
    })
    await ajax("get", "/users")
  })

  it("sends Content-Type header", async () => {
    xhrMock.get("http://localhost/users", (req, res) => {
      expect(req.header("Content-Type")).toEqual(
        "application/json; charset=utf-8"
      )
      return res.status(200).body('{"message":"Ok"}')
    })
    await ajax("get", "/users")
  })

  it("sends Accept header", async () => {
    xhrMock.get("http://localhost/users", (req, res) => {
      expect(req.header("Accept")).toEqual("application/json")
      return res.status(200).body('{"message":"Ok"}')
    })
    await ajax("get", "/users")
  })

  it("returns JSON", async () => {
    xhrMock.get("http://localhost/users", (_req, res) => {
      return res.status(200).body('{"email":"mail@example.com"}')
    })
    await ajax("get", "/users").then((res) => {
      expect(res.data).toEqual({ email: "mail@example.com" })
    })
  })

  it("JSON parse errors get rejected", async () => {
    xhrMock.get("http://localhost/users", (_req, res) => {
      return res.status(200).body('email => "mail@example.com"')
    })
    expect.assertions(1)
    await ajax("get", "/users").catch((e) => {
      expect(e.message).toMatch("Unexpected token")
    })
  })

  it("network errors get rejected", async () => {
    xhrMock.get("http://localhost/users", () => {
      return Promise.reject(new Error())
    })
    expect.assertions(1)
    await ajax("get", "/users").catch((e) => {
      expect(e.message).toEqual("An error occurred during the transaction")
    })
  })

  it("server errors get rejected", async () => {
    xhrMock.get("http://localhost/users", (_req, res) => {
      return res.status(401).body('{"error":"Unauthorized"}')
    })
    expect.assertions(1)
    await ajax("get", "/users").catch((e) => {
      expect(e.error).toEqual("Unauthorized")
    })
  })

  it("server errors parsing errors get rejected", async () => {
    xhrMock.get("http://localhost/users", (_req, res) => {
      return res.status(401).body("Unauthorized")
    })
    expect.assertions(1)
    await ajax("get", "/users").catch((e) => {
      expect(e.message).toMatch("Unexpected token")
    })
  })

  it("params get attached as query string", async () => {
    xhrMock.get("http://localhost/users?name=foo", (_req, res) => {
      return res.status(200).body(`{"name":"foo"}`)
    })
    const { data } = await ajax("get", "/users", { name: "foo" })
    expect(data.name).toEqual("foo")
  })
})

describe("ajax('post')", () => {
  it("sends X-CSRF-TOKEN header", async () => {
    xhrMock.post("http://localhost/users", (req, res) => {
      expect(req.header("X-CSRF-TOKEN")).toEqual(token)
      return res.status(200).body('{"message":"Ok"}')
    })
    await ajax("post", "/users")
  })

  it("sends Content-Type header", async () => {
    xhrMock.post("http://localhost/users", (req, res) => {
      expect(req.header("Content-Type")).toEqual(
        "application/json; charset=utf-8"
      )
      return res.status(200).body('{"message":"Ok"}')
    })
    await ajax("post", "/users")
  })

  it("sends Accept header", async () => {
    xhrMock.post("http://localhost/users", (req, res) => {
      expect(req.header("Accept")).toEqual("application/json")
      return res.status(200).body('{"message":"Ok"}')
    })
    await ajax("post", "/users")
  })

  it("sends JSON data", async () => {
    xhrMock.post("http://localhost/users", (req, res) => {
      expect(req.body()).toEqual('{"email":"mail@example.com"}')
      return res.status(200).body('{"message":"Ok"}')
    })
    await ajax("post", "/users", { email: "mail@example.com" })
  })
})

afterEach(() => xhrMock.teardown())
