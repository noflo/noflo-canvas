noflo = require 'noflo'

class DrawImage extends noflo.Component
  description: 'Draws the specified image'
  icon: 'pencil-square'
  constructor: ->
    @image = null
    @destPoint = null
    @destRect = null
    @sourceRect = null

    @inPorts =
      image: new noflo.Port 'object'
      destPoint: new noflo.Port 'array'
      destRect: new noflo.Port 'array'
      sourceRect: new noflo.Port 'array'

    @outPorts =
      drawImage: new noflo.Port 'object'

    @inPorts.image.on 'data', (image) =>
      @image = image
      @compute()

    @inPorts.destPoint.on 'data', (destPoint) =>
      @destPoint = destPoint
      @compute()

    @inPorts.destRect.on 'data', (destRect) =>
      @destRect = destRect
      @compute()

    @inPorts.sourceRect.on 'data', (sourceRect) =>
      @sourceRect = sourceRect
      @compute()

  compute: () =>
    return unless @outPorts.drawImage.isAttached()
    return unless @image?
    if @destRect? and @sourceRect?
      dx = @destRect[0]
      dy = @destRect[1]
      dw = @destRect[2]
      dh = @destRect[3]
      sx = @sourceRect[0]
      sy = @sourceRect[1]
      sw = @sourceRect[2]
      sh = @sourceRect[3]
      @outPorts.drawImage.send
        'drawImage': [@image, dx, dy, dw, dh, sx, sy, sw, sh]
    else if @destRect? and @destRect.length is 4
      dx = @destRect[0]
      dy = @destRect[1]
      dw = @destRect[2]
      dh = @destRect[3]
      @outPorts.drawImage.send
        'drawImage': [@image, dx, dy, dw, dh]
    else if @destPoint? and @destPoint.length is 2
      dx = @destRect[0]
      dy = @destRect[1]
      @outPorts.drawImage.send
        'drawImage': [@image, dx, dy]

exports.getComponent = -> new DrawImage
