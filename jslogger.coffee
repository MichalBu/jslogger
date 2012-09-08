###

  JSLogger

  @version 1.2
  @author  Dumitru Glavan
  @link    http://jslogger.com
  @link    http://dumitruglavan.com

###

class window.JSLogger

  url: false

  proto: false

  host: "jslogger.com"

  port: "6987"

  track: true

  logWindowErrors: true

  constructor: (options = {})->
    @setOptions(options)
    window.onerror = @windowErrorHandler if @logWindowErrors

  log: (data)->
    @logDataByType("log", data) if @track

  event: (data)->
    @logDataByType("event", data) if @track

  setOptions: (options)->
    @url             = options.url || @url
    @proto           = options.proto || @getCurrentProtocol()
    @host            = options.host || @host
    @port            = options.port || @getPortByProtocol()
    @track           = if typeof options.track isnt "undefined" then options.track else @track
    @logWindowErrors = if typeof options.logWindowErrors isnt "undefined" then options.logWindowErrors else @logWindowErrors

  getCurrentProtocol: ()->
    window.location.protocol.replace(":", "")

  getPortByProtocol: ()->
    return (parseInt(@port, 10) + 1) if @proto is "https"
    return @port if @proto isnt "https"

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

  logDataByType: (type, data)->
    url = @getUrl(type)
    request = @createCORSRequest(url)
    if request
      params = @serialize(data, "dump")
      @sendData(request, params)

  sendData: (request, params)->
    if typeof request.setRequestHeader is "function"
      request.setRequestHeader("Content-type", "application/x-www-form-urlencoded")
    #request.setRequestHeader("Content-length", params.length)
    #request.setRequestHeader("Connection", "close")
    request.send(params) if typeof request.send is "function"
    if request.type and request.type is "text/javascript"
      request.src = "#{request.src}?#{params}"
      body = document.getElementsByTagName("body")[0]
      body.appendChild(request)
      body.removeChild(request)

  serialize: (obj, prefix = "dump")->
    if typeof obj isnt "string"
      obj = if JSON then JSON.stringify(obj) else obj
    "#{prefix}=#{encodeURIComponent(obj)}&_t=#{new Date().getTime()}"

  getUrl: (action)->
    if not @url
      @url = ":proto://:host::port".replace(/:proto/, @proto).replace(/:host/, @host).replace(/:port/, @port)
    "#{@url}/#{action}"

  windowErrorHandler: (msg, url, line)=>
    @log
      msg: msg,
      url: url,
      line: line
