# @runtime noflo-browser
# @name SaveJPEG

noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
  c.description = 'Exports a canvas to JPEG'
  c.icon = 'file-image-o'
  c.inPorts.add 'canvas',
    datatype: 'object'
  c.outPorts.add 'jpeg',
    datatype: 'string'
  c.process (input, output) ->
    return unless input.hasData 'canvas'
    canvas = input.getData 'canvas'
    img = canvas.toDataURL('image/jpeg')
    output.sendDone
      jpeg: img
    return
