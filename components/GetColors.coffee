noflo = require 'noflo'
ColorThief = require 'color-thief'

class GetColors extends noflo.Component
  description: 'Extract the dominant colors of an image'
  icon: 'file-image-o'
  constructor: ->

    @inPorts =
      image: new noflo.Port 'object'
    @outPorts =
      colors: new noflo.Port 'array'
      canvas: new noflo.Port 'object'

    @inPorts.image.on 'begingroup', (group) =>
      @outPorts.canvas.beginGroup group
      @outPorts.colors.beginGroup group
    @inPorts.image.on 'endgroup', (group) =>
      @outPorts.canvas.endGroup group
      @outPorts.colors.endGroup group
    @inPorts.image.on 'disconnect', () =>
      @outPorts.colors.disconnect()
      @outPorts.canvas.disconnect()
    @inPorts.image.on 'data', (image) =>
      thief = new ColorThief
      colors = thief.getPalette image, 10, 10
      @outPorts.colors.send colors
      @outPorts.canvas.send {s: "f"}

exports.getComponent = -> new GetColors
