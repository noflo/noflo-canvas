noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
  c.description = 'Sets the global fill style'
  c.icon = 'pencil-square-o'
  c.inPorts.add 'style',
    datatype: 'string'
  c.outPorts.add 'fillstyle',
    datatype: 'object'
  c.process (input, output) ->
    return unless input.hasData 'style'
    fillStyle =
      type: 'fillStyle'
      value: input.getData 'style'
    output.sendDone
      out: new noflo.IP 'data', fillStyle
    return
