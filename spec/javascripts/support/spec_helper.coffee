fs           = require('fs')
jsdom        = require('jsdom')
coffeescript = require('coffee-script')
require('./spy_helper')

compileCoffeeFilesInDirectory = (files, directory) ->
  testeeSources = []
  files.forEach((path) ->
    path = directory + '/' + path
    path += '.coffee' if (!/\.coffee$/i.test(path))
    testeeCoffeeScriptSource = '' + fs.readFileSync(path)
    testeeSource = coffeescript.compile(testeeCoffeeScriptSource)
    testeeSources.push(testeeSource)
  )
  testeeSources

helper =
  setupWindow: () ->
    testeeSourcePaths = {
      app:
        [
          'jslogger'
        ]
      lib:
        []
    }
    html = '<html><head></head><body></body></html>'
    scripts = [
    ]

    appSources    = compileCoffeeFilesInDirectory(testeeSourcePaths['app'], __dirname + '/../../../')
    testeeSources = appSources

    configuration =
      html:    html
      scripts: scripts
      src:     testeeSources
      done:    (errors, newWindow) ->
        global.window = newWindow # must be last as it releases
                                  # flow control to jasmine

    jsdom.env(configuration)

    beforeEach(() ->
      waitsFor(() ->
        return typeof window isnt "undefined"
      )
      runs(() ->
       throw new Error("window.document was not set") unless window.document
      )
    )

helper.setupWindow()

global.newUninitialized = () ->
  args = []
  Array.prototype.push.apply(args, arguments)
  klass = args.shift()
  createInstanceOfKlass = (() ->
    F = (args) ->
      klass.apply(this, args)

    F.prototype = klass.prototype

    () ->
      new F(arguments);
  )()
  originalInitialize         = klass.prototype.initialize
  klass.prototype.initialize = () ->
  instance                   = createInstanceOfKlass.apply(this, args)
  klass.prototype.initialize = originalInitialize
  instance

global.getObjectClass = (obj)->
  if obj and obj.constructor and obj.constructor.toString
    arr = obj.constructor.toString().match(/function\s*(\w+)/)
    if arr and arr.length == 2
      return arr[1]
  return undefined

global.getParentClass = (obj)->
  getObjectClass(obj.constructor.__super__)

module.exports = helper
