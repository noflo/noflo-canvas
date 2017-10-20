noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
  c.description = 'Group drawing commands or primatives into a flattened array.'
  c.icon = 'folder-o'
  c.inPorts.add 'items',
    datatype: 'object'
    addressable: true
  c.outPorts.add 'group',
    datatype: 'array'
  c.process (input, output) ->
    indexesWithData = input.attached('items').filter (idx) ->
      input.hasData ['items', idx]
    return unless indexesWithData.length is input.attached('items').length
    group = []
    indexesWithData.forEach (idx) ->
      data = input.getData ['items', idx]
      if Array.isArray data
        group = group.concat data
        return
      group.push data
    output.sendDone
      group: group
