noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
  c.description = 'Convert a RGB array to a hex value'
  c.inPorts.add 'in',
    datatype: 'array'
  c.outPorts.add 'out',
    datatype: 'string'
  
  hex = (n) ->
    s = n.toString(16)
    if s.length is 1
      s = "0"+s
    return s

  c.process (input, output) ->
    return unless input.hasData 'in'
    rgb = input.getData 'in'
    out = "#"+hex(rgb[0])+hex(rgb[1])+hex(rgb[2])
    output.sendDone
      out: out
    return
