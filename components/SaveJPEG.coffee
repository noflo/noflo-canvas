# @runtime noflo-browser
# @name SaveJPEG

noflo = require 'noflo'

class SaveJPEG extends noflo.Component
  description: 'Exports a canvas to JPEG'
  icon: 'file-image-o'
  constructor: ->
    @inPorts =
      canvas: new noflo.Port 'object'

    @outPorts =
      jpeg: new noflo.Port 'object'

    @inPorts.canvas.on 'data', (canvas) =>
      img = canvas.toDataURL('image/jpeg')
      if @outPorts.jpeg.isAttached()
        @outPorts.jpeg.send img

exports.getComponent = -> new SaveJPEG
