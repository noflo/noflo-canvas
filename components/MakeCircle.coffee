noflo = require 'noflo'

class MakeCircle extends noflo.Component
  description: 'Creates an array representing a circle (full arc)'
  icon: 'circle-o'
  constructor: ->
    @circle = []
    @circle[0] = null # x
    @circle[1] = null # y
    @circle[2] = null # radius
    @circle[3] = 0 # start radians
    @circle[4] = Math.PI*2 # end radians = TAU for a full circle
    @circle[5] = false # anticlockwise
    @circle.type = 'arc'

    @inPorts =
      center: new noflo.Port 'array'
      radius: new noflo.Port 'number'
      circle: new noflo.Port 'array'

    @outPorts =
      circle: new noflo.Port 'array'

    @inPorts.center.on 'data', (data) =>
      @circle[0] = data[0]
      @circle[1] = data[1]
      @compute()

    @inPorts.radius.on 'data', (data) =>
      @circle[2] = data
      @compute()

    @inPorts.circle.on 'data', (data) =>
      @circle[0] = data[0]
      @circle[1] = data[1]
      @circle[2] = data[2]
      @compute()

  compute: ->
    if @outPorts.circle.isAttached() and @circle.indexOf(null) is -1
      @outPorts.circle.send @circle

exports.getComponent = -> new MakeCircle
