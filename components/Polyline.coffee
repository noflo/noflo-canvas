noflo = require 'noflo'

class Polyline extends noflo.Component
  description: 'Makes a 2D polyline given a number of points'
  icon: 'pencil-square'
  constructor: ->
    @points = []
    @inPorts =
      points: new noflo.ArrayPort 'array'

    @outPorts =
      polyline: new noflo.Port 'object'

    @inPorts.points.on 'data', (points) =>
      @points = points
      if @outPorts.polyline.isAttached()
        @outPorts.polyline.send {'polyline': @points}

exports.getComponent = -> new Polyline
