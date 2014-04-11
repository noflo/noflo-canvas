noflo = require 'noflo'

class Stroke extends noflo.Component
  description: 'Paints the received polyline as a line'
  icon: 'pencil-square'
  constructor: ->
    @polyline = null
    
    @inPorts =
      polyline: new noflo.Port 'object'
    @outPorts =
      stroke: new noflo.Port 'object'

    @inPorts.polyline.on 'data', (polyline) =>
      @polyline = polyline
      if @outPorts.stroke.isAttached()
          @outPorts.stroke.send {'stroke': @polyline}

exports.getComponent = -> new Stroke
