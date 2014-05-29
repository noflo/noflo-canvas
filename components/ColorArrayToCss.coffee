noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
  c.inPorts.add 'in', (event, payload) ->
    if event is 'disconnect'
      c.outPorts.out.disconnect()
    
    return unless event is 'data'
    hex = (n) ->
      return n.toString(16)
    rgb = payload
    out = "#"+hex(rgb[0])+hex(rgb[1])+hex(rgb[2])
    c.outPorts.out.send out
  c.outPorts.add 'out'
  c
