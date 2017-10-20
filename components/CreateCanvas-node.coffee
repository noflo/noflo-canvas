# @runtime noflo-nodejs
# @name CreateCanvas

noflo = require 'noflo'
Canvas = require 'canvas'

exports.getComponent = ->
  c = new noflo.Component
  c.description = 'Makes a Canvas with given dimensions'
  c.icon = 'pencil-square'
  c.inPorts.add 'width',
    datatype: 'int'
  c.inPorts.add 'height',
    datatype: 'int'
  c.outPorts.add 'canvas',
    datatype: object
  c.process (input, output) ->
    return unless input.hasData 'width', 'height'
    [width, height] = input.getData 'width', 'height'
    canvas = new Canvas width, height
    output.sendDone
      canvas: canvas
    return
