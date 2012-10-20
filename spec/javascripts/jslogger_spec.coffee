spec_helper = require("./support/spec_helper")

describe "JSLogger", ()->
  logger = undefined

  beforeEach ()->
    window.location.protocol = "protocol:"
    logger = new window.JSLogger

  it "has a url", ()->
  	expect(logger.url).toEqual(false)

  it "has a protocol", ()->
  	expect(logger.proto).toEqual("protocol")

  it "has a port", ()->
  	expect(logger.port).toEqual(80)

  it "has a portSSL", ()->
    expect(logger.portSSL).toEqual(143)

  it "tracks data by default", ()->
  	expect(logger.track).toEqual(true)

  it "logs the window errors by default", ()->
  	expect(logger.logWindowErrors).toEqual(true)

  describe "constructor", ()->
  	beforeEach ()->
      spyOn(logger, "setOptions")
      window.onerror = undefined

  	it "sets the default options", ()->
      options = {}
      logger.constructor(options)
      expect(logger.setOptions).toHaveBeenCalledWith(options)

    describe "when the logWindowErrors is true", ()->
      it "sets the window onerror handler", ()->
        logger.logWindowErrors = true
        logger.constructor()
        expect(window.onerror).toEqual(logger.windowErrorHandler)

    describe "when the logWindowErrors is false", ()->
      it "does not set the window onerror handler", ()->
        logger.logWindowErrors = false
        logger.constructor()
        expect(window.onerror).toEqual(undefined)

  describe "setOptions", ()->
    it "sets the given options as class properties", ()->
      options =
        url: "url"
        proto: "proto"
        host: "host"
        track: "track"
        logWindowErrors: "logWindowErrors"
      logger.setOptions(options)
      for property, value of options
        expect(logger[property]).toEqual(value)

  describe "getCurrentProtocol", ()->
    it "returns the current protocol from the location object", ()->
      expect(logger.getCurrentProtocol()).toEqual("protocol")

  describe "getPortByProtocol", ()->    
    describe "when the protocol is https", ()->
      beforeEach ()->
        logger.proto = "https"
      
      it "returns the portSSL", ()->
        expect(logger.getPortByProtocol()).toEqual(143)

    describe "when the protocol is not https", ()->
      beforeEach ()->
        logger.proto = "http"
      
      it "returns the port", ()->
        expect(logger.getPortByProtocol()).toEqual(80)

  describe "createCORSRequest", ()->
    beforeEach ()->
      window.XMLHttpRequest = undefined
      window.XDomainRequest = undefined

    describe "when XMLHttpRequest object is available", ()->
      xhr = undefined

      beforeEach ()->
        xhr = createSpyWithStubs("xhr", {open: null})
        xhr.withCredentials = true
        window.XMLHttpRequest = ()->
          xhr

      it "opens an async post request to the given url", ()->
        logger.createCORSRequest("url")
        expect(xhr.open).toHaveBeenCalledWith("post", "url", true)

      it "returns the xhr object", ()->
        expect(logger.createCORSRequest("url")).toEqual(xhr)

    describe "when XMLHttpRequest is not available and the XDomainRequest object is available", ()->
      xhr = undefined

      beforeEach ()->
        xhr = createSpyWithStubs("xhr", {open: null})
        window.XDomainRequest = ()->
          xhr

      it "opens an async post request to the given url", ()->
        logger.createCORSRequest("url")
        expect(xhr.open).toHaveBeenCalledWith("post", "url")

      it "returns the xhr object", ()->
        expect(logger.createCORSRequest("url")).toEqual(xhr)

    describe "when no request XMLHttpRequest and XDomainRequest object exists", ()->
      beforeEach ()->
        spyOn(window.document, "createElement").andReturn({})

      it "returns a script DOM element", ()->
        returnedDomScript = {}
        returnedDomScript.type = "text/javascript"
        returnedDomScript.src = "url"
        expect(logger.createCORSRequest("url")).toEqual(returnedDomScript)

    describe "when the protocol is https", ()->
      beforeEach ()->
        xhr = createSpyWithStubs("xhr", {open: null})
        window.XDomainRequest = ()->
          xhr
        spyOn(window.document, "createElement").andReturn({})

      it "returns a script DOM element", ()->
        logger.proto = "https"
        returnedDomScript = {}
        returnedDomScript.type = "text/javascript"
        returnedDomScript.src = "url"
        expect(logger.createCORSRequest("url")).toEqual(returnedDomScript)

  describe "log", ()->
    beforeEach ()->
      spyOn(logger, "logDataByType")

    describe "when in track mode", ()->
      beforeEach ()->
        logger.track = true

      it "logs the given data by type log", ()->
        logger.log("data")
        expect(logger.logDataByType).toHaveBeenCalledWith("log", "data")

    describe "when not in track mode", ()->
      beforeEach ()->
        logger.track = false

      it "does not log the given data by type log", ()->
        logger.log("data")
        expect(logger.logDataByType).wasNotCalled()

  describe "event", ()->
    beforeEach ()->
      spyOn(logger, "logDataByType")

    describe "when in track mode", ()->
      beforeEach ()->
        logger.track = true

      it "logs the given data by type event", ()->
        logger.event("data")
        expect(logger.logDataByType).toHaveBeenCalledWith("event", "data")

    describe "when not in track mode", ()->
      beforeEach ()->
        logger.track = false

      it "does not log the given data by type event", ()->
        logger.event("data")
        expect(logger.logDataByType).wasNotCalled()

  describe "logDataByType", ()->
    beforeEach ()->
      spyOn(logger, "getUrl").andReturn("url")
      spyOn(logger, "createCORSRequest").andReturn("request")
      spyOn(logger, "serialize").andReturn("params")
      spyOn(logger, "sendData")

    it "gets the log url", ()->
      logger.logDataByType("type", "data")
      expect(logger.getUrl).toHaveBeenCalledWith("type")

    it "creates the cors request object", ()->
      logger.logDataByType("type", "data")
      expect(logger.createCORSRequest).toHaveBeenCalledWith("url")

    describe "when a valid request is returned", ()->
      it "serializes the data with the dump prefix", ()->
        logger.logDataByType("type", "data")
        expect(logger.serialize).toHaveBeenCalledWith("data", "dump")

      it "sends the data", ()->
        logger.logDataByType("type", "data")
        expect(logger.sendData).toHaveBeenCalledWith("request", "params")

  describe "sendData", ()->
    request = undefined

    beforeEach ()->
      request = {}
      request.src = "src"
    
    describe "when the given request can set headers", ()->
      beforeEach ()->
        request.setRequestHeader = createSpy("SetRequestHeader")

      it "sets the Content-Type header", ()->
        logger.sendData(request, "params")
        expect(request.setRequestHeader).toHaveBeenCalledWith("Content-type", "application/x-www-form-urlencoded")

    describe "when the request can be sent", ()->
      beforeEach ()->
        request.send = createSpy("Send")

      it "send the params", ()->
        logger.sendData(request, "params")
        expect(request.send).toHaveBeenCalledWith("params")

    describe "when the request is a script element", ()->
      body            = undefined
      modifiedRequest = undefined

      beforeEach ()->
        request.type = "text/javascript"
        modifiedRequest =
          type: "text/javascript"
          src: "src?params"
        body = createSpyWithStubs("Body", {appendChild: null, removeChild: null})
        spyOn(window.document, "getElementsByTagName").andReturn([body])

      it "appends the script element to body", ()->
        logger.sendData(request, "params")
        expect(body.appendChild).toHaveBeenCalledWith(modifiedRequest)

      it "removes the script element from body", ()->
        logger.sendData(request, "params")
        expect(body.removeChild).toHaveBeenCalledWith(modifiedRequest)

  describe "serialize", ()->
    beforeEach ()->
      date =
        getTime: ()->
          "timestamp"
      spyOn(window, "Date").andReturn(date)

    it "returns a serialized string from the given object, assigned to the given prefix", ()->
      resultSerializedUriEncodedString = "dump=%7B%22type%22%3A%22click%22%2C%22target%22%3A%22red%20button%22%7D&_t=timestamp"
      expect(logger.serialize({type: "click", target: "red button"}, "dump")).toEqual(resultSerializedUriEncodedString)

  describe "getUrl", ()->
    it "returns the log url of the given action type", ()->
      expect(logger.getUrl("action")).toEqual("protocol://jslogger.com:80/action")

  describe "windowErrorHandler", ()->
    beforeEach ()->
      spyOn(logger, "log")

    it "logs the given params", ()->
      logger.windowErrorHandler("message", "url", "line")
      expect(logger.log).toHaveBeenCalledWith({msg: "message", url: "url", line: "line"})

