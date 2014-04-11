noflo = require 'noflo'

class Fill extends noflo.Component
  description: 'Paints the received polyline as a polygon'
  icon: 'pencil-square'
  constructor: ->
    @polyline = null

    @inPorts =
      polyline: new noflo.Port 'object'
    @outPorts =
      fill: new noflo.Port 'object'

    @inPorts.polyline.on 'data', (polyline) =>
      @polyline = polyline
      if @outPorts.fill.isAttached()
        @outPorts.fill.send {'fill': @polyline}

exports.getComponent = -> new Fill
