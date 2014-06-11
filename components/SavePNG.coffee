# @runtime noflo-browser
# @name SavePNG

noflo = require 'noflo'

class SavePNG extends noflo.Component
  description: 'Exports a canvas to PNG'
  icon: 'file-image-o'
  constructor: ->
    @inPorts =
      canvas: new noflo.Port 'object'

    @outPorts =
      png: new noflo.Port 'object'

    @inPorts.canvas.on 'data', (canvas) =>
      img = canvas.toDataURL('image/png')
      if @outPorts.png.isAttached()
        @outPorts.png.send img

exports.getComponent = -> new SavePNG