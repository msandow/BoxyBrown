CompiledFile = require('./CompiledFile.coffee')
StringFile = require('./StringFile.coffee')
sass = require('node-sass')
arrayUnique = require('./Utils.coffee').arrayUnique
_console = require('PrettyConsole')
Base64 = require('./Base64.coffee')
fs = require('fs')
path = require('path')


module.exports = class ScssCss extends CompiledFile

  constructor: (conf) ->
    super(conf)
    @sassIncludePaths = conf.sassIncludePaths
    @

  setUp: (doBuild = true) ->
    @compiledStream = new StringFile('text/css')
    @compiledSourceMap = new StringFile('application/json') if @debug
    
    @build() if doBuild

    @


  getSassRenderConfigs: ->
    {
      file: @source
      #data: newData
      sourceMap: if @debug then @route + ".map" else undefined
      outputStyle: 'compressed'
      sourceMapContents: @debug
      includePaths: @sassIncludePaths
    }


  build: () ->
    if !@compiling and !@killed
      @compiling = true
      @compiledStream.reset()
      @compiledSourceMap.reset() if @debug
      @sourceFiles = []
      
      fs.readFile(@source, 'utf8', (err, data)=>
#        Base64.direct(data, @source, (err, newData)=>
        sass.render(@getSassRenderConfigs(),
        (err, result) =>
          if err
            msg = err.message
            msg += " - #{err.file}" if err.file isnt undefined
            msg += " #{err.line}:#{err.column}" if err.line isnt undefined

            @onBuildError(msg)
            @compiling = false
            @hasBuildError = true
            return

          @hasBuildError = false
          @sourceFiles = arrayUnique(result.stats.includedFiles.concat(path.resolve(@source)))

          if @debug
            @compiledStream.set(result.css.toString().replace(/(sourceMappingURL=)(.+?)(\s\*\/)/gm, "$1#{@route}.map$3"))
            @compiledSourceMap.set(result.map.toString())
          else
            @compiledStream.set(result.css.toString())

          @setUpWatchers() if @debug
          _console.info("#{path.normalize(@source)} compiled") if @debug and not @silent

          @compiling = false
        )
#        )
      )


  run: (cb) ->
    @setUp(false)
    
    fs.readFile(@source, 'utf8', (err, data)=>
#      Base64.direct(data, @source, (err, newData)=>
      sass.render(@getSassRenderConfigs(),
      (err, result) =>
        if err
          console.error(err.message)
          cb.call(@)
          return

        if @debug
          @compiledStream.set(result.css.toString().replace(/(sourceMappingURL=)(.+?)(\s\*\/)/gm, "$1#{@route}.map$3"))
          @compiledSourceMap.set(result.map.toString())
        else
          @compiledStream.set(result.css.toString())

        cb.call(@)
      )
#      )
    )