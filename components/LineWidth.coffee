noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
  c.description = 'Sets the line width'
  c.icon = 'pencil-square'
  c.inPorts.add 'width',
    datatype: 'number'
  c.outPorts.add 'linewidth',
    datatype: 'object'
  c.process (input, output) ->
    return unless input.hasData 'width'
    linewidth =
      type: 'lineWidth'
      value: input.getData 'width'
    output.sendDone
      out: new noflo.IP 'data', linewidth
    return
