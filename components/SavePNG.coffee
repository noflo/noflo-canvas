# @runtime noflo-browser
# @name SavePNG

noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
  c.description = 'Exports a canvas to PNG'
  c.icon = 'file-image-o'
  c.inPorts.add 'canvas',
    datatype: 'object'
  c.outPorts.add 'png',
    datatype: 'string'
  c.process (input, output) ->
    return unless input.hasData 'canvas'
    canvas = input.getData 'canvas'
    img = canvas.toDataURL('image/png')
    output.sendDone
      png: img
    return
