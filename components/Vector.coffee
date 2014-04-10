noflo = require 'noflo'

class Vector extends noflo.Component
  description: 'Creates a vector with 2 dimensions'
  icon: 'pencil-square'
  constructor: ->
    @x = null
    @y = null

    @inPorts =
      x: new noflo.Port 'number'
      y: new noflo.Port 'number'
      coords: new noflo.Port 'array'

    @outPorts =
      vector: new noflo.Port 'object'

    @inPorts.x.on 'data', (data) =>
      @x = data
      @compute()

    @inPorts.y.on 'data', (data) =>
      @y = data
      @compute()

    @inPorts.coords.on 'data', (data) =>
      @x = data[0]
      @y = data[1]
      @compute()

  compute: ->
    if @x? and @y?
      if @outPorts.vector.isAttached()
        @outPorts.vector.send [@x, @y]

exports.getComponent = -> new Vector
