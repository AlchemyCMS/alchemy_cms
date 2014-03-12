window.Alchemy = {} if typeof(Alchemy) is "undefined"

Alchemy.Browser =
  isiPhone: navigator.userAgent.match(/iPhone/i) isnt null
  isiPad: navigator.userAgent.match(/iPad/i) isnt null
  isiPod: navigator.userAgent.match(/iPod/i) isnt null
  isiOS: navigator.userAgent.match(/iPad|iPhone|iPod/i) isnt null
  isFirefox: navigator.userAgent.match(/Firefox/i) isnt null
  isChrome: navigator.userAgent.match(/Chrome/i) isnt null
  isSafari: navigator.userAgent.match(/AppleWebKit/) and not navigator.userAgent.match(/Chrome/)
  isIE: navigator.userAgent.match(/MSIE/i) isnt null
  getVersion: (browser) ->
    if Alchemy.Browser["is" + browser]
      parseInt(navigator.userAgent.match(new RegExp(browser + ".[0-9]+", "i"))[0].replace(new RegExp(browser + "."), ""), 10)
    else
      null

Alchemy.Browser.ChromeVersion = Alchemy.Browser.getVersion("Chrome")
Alchemy.Browser.FirefoxVersion = Alchemy.Browser.getVersion("Firefox")
Alchemy.Browser.SafariVersion = Alchemy.Browser.getVersion("Safari")
Alchemy.Browser.IEVersion = Alchemy.Browser.getVersion("MSIE")
Alchemy.Browser.isWebKit = Alchemy.Browser.isChrome || Alchemy.Browser.isSafari
