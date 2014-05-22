noflo = require 'noflo'
ColorThief = require 'color-thief'

class GetColors extends noflo.Component
  description: 'Extract the dominant colors of an image'
  icon: 'file-image-o'
  constructor: ->
    @image = null

    @inPorts =
      image: new noflo.Port 'object'
    @outPorts =
      colors: new noflo.Port 'array'

    @inPorts.image.on 'data', (image) =>
      @image = image
      @calculate()
    @inPorts.image.on 'disconnect', (image) =>
      @outPorts.colors.disconnect()

  calculate: ->
    thief = new ColorThief
    colors = thief.getPalette @image
    id = if noflo.isBrowser() then @image.src else @image
    @outPorts.colors.beginGroup id
    @outPorts.colors.send colors
    @outPorts.colors.endGroup()

exports.getComponent = -> new GetColors
