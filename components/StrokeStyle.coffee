noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
  c.description = 'Sets the global stroke style'
  c.icon = 'pencil-square-o'
  c.inPorts.add 'style',
    datatype: 'string'
  c.outPorts.add 'strokestyle',
    datatype: 'object'
  c.process (input, output) ->
    return unless input.hasData 'style'
    strokeStyle =
      type: 'strokeStyle'
      value: input.getData 'style'
    output.sendDone
      out: new noflo.IP 'data', strokeStyle
    return
