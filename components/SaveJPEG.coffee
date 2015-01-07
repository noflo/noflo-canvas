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
      png: new noflo.Port 'object'

    @inPorts.canvas.on 'data', (canvas) =>
      img = canvas.toDataURL('image/jpeg')
      if @outPorts.png.isAttached()
        @outPorts.png.send img

exports.getComponent = -> new SaveJPEG
