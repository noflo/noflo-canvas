noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
  
  hex = (n) ->
    s = n.toString(16)
    if s.length is 1
      s = "0"+s
    return s
    
  c.inPorts.add 'in', (event, payload) ->
    if event is 'disconnect'
      c.outPorts.out.disconnect()
    
    return unless event is 'data'
    rgb = payload
    out = "#"+hex(rgb[0])+hex(rgb[1])+hex(rgb[2])
    c.outPorts.out.send out
  c.outPorts.add 'out'
  c
