noflo = require 'noflo'

class Circle extends noflo.Component
  description: 'Creates an array representing a circle (full arc)'
  icon: 'pencil-square'
  constructor: ->
    @circle = []
    @circle[0] = null # x
    @circle[1] = null # y
    @circle[2] = null # radius
    @circle[3] = 0 # start radians
    @circle[4] = Math.PI*2 # end radians = Tau for a full arc
    @circle.type = 'arc'

    @inPorts =
      x: new noflo.Port 'number'
      y: new noflo.Port 'number'
      radius: new noflo.Port 'number'
      circle: new noflo.Port 'array'

    @outPorts =
      circle: new noflo.Port 'array'

    @inPorts.x.on 'data', (data) =>
      @circle[0] = data
      @compute()

    @inPorts.y.on 'data', (data) =>
      @circle[1] = data
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

exports.getComponent = -> new Circle
