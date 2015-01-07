# @runtime noflo-nodejs
# @name SaveJPEG

noflo = require 'noflo'
Canvas = require 'canvas'
fs = require 'fs'

class SaveJPEG extends noflo.Component
  description: 'Save a canvas to JPEG'
  icon: 'file-image-o'
  constructor: ->
    @filename = 'out.jpg'

    @inPorts = new noflo.InPorts
      canvas:
        datatype: "object"
      filename:
        datatype: "string"
    @outPorts =
      png: new noflo.Port 'string'

    @inPorts.canvas.on 'data', (canvas) =>
      out = fs.createWriteStream(@filename)
      stream = canvas.createJPEGStream()
      
      stream.on 'data', (chunk) ->
        out.write(chunk)
      stream.on 'end', () =>
        @outPorts.png.send @filename if @outPorts.png.isAttached()

    @inPorts.filename.on 'data', (filename) =>
      @filename = filename

exports.getComponent = -> new SaveJPEG
