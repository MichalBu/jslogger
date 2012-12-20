###

  JSLogger

  @version 1.6
  @author  Dumitru Glavan
  @link    http://jslogger.com
  @link    http://dumitruglavan.com

###

class window.JSLogger

  url: false

  proto: false

  host: "jslogger.com"

  port: 80

  portSSL: 443

  track: true

  apiKey: null

  logWindowErrors: true

  jsonParserPath: "//jslogger.com/json2.js"

  constructor: (options = {})->
    @setOptions(options)
    @loadJSONParser() if typeof window.JSON isnt "object"
    window.onerror = @windowErrorHandler if @logWindowErrors

  log: (data, extraParams)->
    @logDataByType("log", data, extraParams) if @track

  event: (data, extraParams)->
    @logDataByType("event", data, extraParams) if @track

  setOptions: (options)->
    @url             = options.url || @url
    @proto           = options.proto || @getCurrentProtocol()
    @host            = options.host || @host
    @portSSL         = options.portSSL || @portSSL
    @port            = options.port || @getPortByProtocol()
    @apiKey          = options.apiKey || @apiKey
    @track           = if typeof options.track isnt "undefined" then options.track else @track
    @logWindowErrors = if typeof options.logWindowErrors isnt "undefined" then options.logWindowErrors else @logWindowErrors

  getCurrentProtocol: ()->
    window.location.protocol.replace(":", "")

  getPortByProtocol: ()->
    if @proto is "https" then @portSSL else @port

  createCORSRequest: (url)->
    xhr = if typeof XMLHttpRequest isnt "undefined" then new XMLHttpRequest() else null
    if @proto isnt "https" and xhr and "withCredentials" of xhr
      xhr.open("post", url, true)
    else if @proto isnt "https" and typeof XDomainRequest isnt "undefined"
      xhr = new XDomainRequest()
      xhr.open("post", url)
    else
      xhr = document.createElement("script")
      xhr.type = "text/javascript"
      xhr.src = url
    return xhr

  logDataByType: (type, data, extraParams)->
    url = @getUrl(type)
    request = @createCORSRequest(url)
    if request
      params = @serialize(data, "dump")
      params = "#{params}&#{@serialize(extraParams, "extra_params")}" if extraParams
      params = "#{params}&key=#{@apiKey}" if @apiKey
      params = "#{params}&_t=#{new Date().getTime()}"
      @sendData(request, params)

  sendData: (request, params)->
    if typeof request.setRequestHeader is "function"
      request.setRequestHeader("Content-type", "application/x-www-form-urlencoded")
    #request.setRequestHeader("Content-length", params.length)
    #request.setRequestHeader("Connection", "close")
    request.send(params) if typeof request.send is "function" or typeof request.send is "object"
    if request.type and request.type is "text/javascript"
      request.src = "#{request.src}?#{params}"
      body = document.getElementsByTagName("body")[0]
      body.appendChild(request)
      body.removeChild(request)

  serialize: (obj, prefix = "dump")->
    if typeof obj isnt "string"
      obj = if JSON then JSON.stringify(obj) else obj
    "#{prefix}=#{encodeURIComponent(obj)}"

  getUrl: (action)->
    if not @url
      @url = ":proto://:host::port".replace(/:proto/, @proto).replace(/:host/, @host).replace(/:port/, @port)
    "#{@url}/#{action}"

  loadJSONParser: ()->
    jsonScript = document.createElement("script")
    jsonScript.type = "text/javascript"
    jsonScript.src = @jsonParserPath
    head = document.getElementsByTagName("head")[0]
    head.appendChild(jsonScript)

  windowErrorHandler: (msg, url, line)=>
    @log
      msg: msg
      url: url
      line: line
