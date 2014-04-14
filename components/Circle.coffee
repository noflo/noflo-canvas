noflo = require 'noflo'

TAU = Math.PI*2

class Circle extends noflo.Component
  description: 'Creates a circle (full arc)'
  icon: 'pencil-square'
  constructor: ->
    @x = null
    @y = null
    @radius = null

    @inPorts =
      x: new noflo.Port 'number'
      y: new noflo.Port 'number'
      radius: new noflo.Port 'number'
      circle: new noflo.Port 'array'

    @outPorts =
      circle: new noflo.Port 'array'

    @inPorts.x.on 'data', (data) =>
      @x = data
      @compute()

    @inPorts.y.on 'data', (data) =>
      @y = data
      @compute()

    @inPorts.radius.on 'data', (data) =>
      @radius = data
      @compute()

    @inPorts.circle.on 'data', (data) =>
      @x = data[0]
      @y = data[1]
      @radius = data[2]
      @compute()

  compute: ->
    if @outPorts.circle.isAttached() and @x? and @y? and @radius
      @outPorts.circle.send {"arc": [@x, @y, @radius, 0, TAU]}

exports.getComponent = -> new Circle
