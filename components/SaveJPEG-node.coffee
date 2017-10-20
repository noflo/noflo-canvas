# @runtime noflo-nodejs
# @name SaveJPEG

noflo = require 'noflo'
Canvas = require 'canvas'
fs = require 'fs'

exports.getComponent = ->
  c = new noflo.Component
  c.description = 'Exports a canvas to JPEG'
  c.icon = 'file-image-o'
  c.inPorts.add 'canvas',
    datatype: 'object'
  c.inPorts.add 'filename',
    datatype: 'string'
    default: 'out.jpeg'
  c.outPorts.add 'jpeg',
    datatype: 'string'
  c.process (input, output) ->
    return unless input.hasData 'canvas'
    return if input.attached('filename').length and not input.hasData 'filename'
    canvas = input.getData 'canvas'
    filename = 'out.jpeg'
    if input.hasData 'filename'
      input.getData 'filename'

    out = fs.createWriteStream(filename)
    stream = canvas.createJPEGStream()
    
    stream.on 'data', (chunk) ->
      out.write(chunk)
    stream.on 'end',  ->
      output.sendDone
        jpeg: filename
    return
