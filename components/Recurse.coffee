noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
  c.description = 'Makes a translation recursive.'
  c.icon = 'retweet'
  c.inPorts.add 'recursables',
    datatype: 'object'
    description: 'Only translate is recursable'
  c.inPorts.add 'count',
    datatype: 'number'
  c.outPorts.add 'recurse',
    datatype: 'object'
  c.recurses = {}
  c.tearDown = (callback) ->
    c.recurses = {}
    do callback
  c.process (input, output) ->
    unless c.recurses[input.scope]
      c.recurses[input.scope] =
        type: 'recurse'
        recursables: []
        count: null
    if input.hasData 'count'
      c.recurses[input.scope].count = input.getData 'count'
      unless c.recurses[input.scope].recursables.length
        output.done()
        return
      output.sendDone
        recurse: c.recurses[input.scope]
      return
    indexesWithData = input.attached('recursables').filter (idx) ->
      input.hasData ['recursables', idx]
    return unless indexesWithData.length
    indexesWithData.forEach (idx) ->
      data = input.getData ['recursables', idx]
      c.recurses[input.scope].recursables[idx] = data
    output.sendDone
      recurse: c.recurses[input.scope]
    return
