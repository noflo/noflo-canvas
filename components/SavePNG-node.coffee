# @runtime noflo-nodejs
# @name SavePNG

noflo = require 'noflo'
Canvas = require 'canvas'
fs = require 'fs'

exports.getComponent = ->
  c = new noflo.Component
  c.description = 'Exports a canvas to PNG'
  c.icon = 'file-image-o'
  c.inPorts.add 'canvas',
    datatype: 'object'
  c.inPorts.add 'filename',
    datatype: 'string'
    default: 'out.png'
  c.outPorts.add 'png',
    datatype: 'string'
  c.process (input, output) ->
    return unless input.hasData 'canvas'
    return if input.attached('filename').length and not input.hasData 'filename'
    canvas = input.getData 'canvas'
    filename = 'out.png'
    if input.hasData 'filename'
      input.getData 'filename'

    out = fs.createWriteStream(filename)
    stream = canvas.createPNGStream()
    
    stream.on 'data', (chunk) ->
      out.write(chunk)
    stream.on 'end',  ->
      output.sendDone
        png: filename
    return
