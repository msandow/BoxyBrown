fs = require('fs')

ut = {}

ut.arrayUnique = (arr = []) ->
  retArr = []
  hash = {}

  for item in arr
    if ['number', 'string'].indexOf(typeof item) > -1
      if hash[item] is undefined
        retArr.push(item)
        hash[item] = true
    else
      retArr.push(item)

  retArr


ut.escapeRegExp = (str) ->
  str.replace(/[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, "\\$&")


ut.TokenReplacer = (path, tokens, cb) ->
  fs.readFile(path, {encoding: 'utf-8'}, (err, data)=>
    cb(err, null) if err

    while /#\{(.*?)\}/gm.test(data)
      finds = ut.arrayUnique(data.match(/#\{(.*?)\}/gm))
      replaces = finds.map((f)=>
        str = f.substring(2, f.length-1)
        return if tokens[str] isnt undefined then tokens[str] else ''
      )

      for find, idx in finds
        str = if typeof replaces[idx] is 'object' then JSON.stringify(replaces[idx]) else replaces[idx]
        data = data.replace(new RegExp(ut.escapeRegExp(find),'gm'), str)

    cb(null, data)
  )


module.exports = ut