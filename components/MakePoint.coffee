noflo = require 'noflo'

class MakePoint extends noflo.Component
  description: 'Creates an array representing a point'
  icon: 'pencil-square'
  constructor: ->
    @point = []
    @point[0] = null
    @point[1] = null
    @point.type = 'point'

    @inPorts =
      x: new noflo.Port 'number'
      y: new noflo.Port 'number'
      point: new noflo.Port 'array'

    @outPorts =
      point: new noflo.Port 'array'

    @inPorts.x.on 'data', (data) =>
      @point[0] = data
      @compute()

    @inPorts.y.on 'data', (data) =>
      @point[1] = data
      @compute()

    @inPorts.point.on 'data', (data) =>
      @point[0] = data[0]
      @point[1] = data[1]
      @compute()

  compute: ->
    if @outPorts.point.isAttached() and @point.indexOf(null) is -1
      @outPorts.point.send @point

exports.getComponent = -> new MakePoint
