# @runtime noflo-nodejs
# @name SavePNG

noflo = require 'noflo'
Canvas = require 'canvas'
fs = require 'fs'

class SavePNG extends noflo.Component
  description: 'Save a canvas to PNG'
  icon: 'file-image-o'
  constructor: ->
    @filename = 'out.png'

    @inPorts = new noflo.InPorts
      canvas:
        datatype: "object"
      filename:
        datatype: "string"

    @inPorts.canvas.on 'data', (canvas) =>
      out = fs.createWriteStream(@filename)
      stream = canvas.createPNGStream()
      
      stream.on 'data', (chunk) ->
        out.write(chunk)

    @inPorts.filename.on 'data', (filename) =>
      @filename = filename

exports.getComponent = -> new SavePNG