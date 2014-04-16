noflo = require 'noflo'

class Arc extends noflo.Component
  description: 'Creates an array representing an arc'
  icon: 'power-off'
  constructor: ->
    @arc = []
    @arc[0] = null # center x
    @arc[1] = null # center y
    @arc[2] = null # radius
    @arc[3] = null # start angle (radians)
    @arc[4] = null # end angle (radians)
    @arc[5] = false # anticlockwise (boolean)
    @arc.type = 'arc'

    @inPorts =
      center: new noflo.Port 'array'
      radius: new noflo.Port 'number'
      start: new noflo.Port 'number'
      end: new noflo.Port 'number'
      reverse: new noflo.Port 'boolean'
      arc: new noflo.Port 'array'

    @inPorts.start.description = 'in radians'
    @inPorts.end.description = 'in radians'
    @inPorts.reverse.description = 'anticlockwise'

    @outPorts =
      arc: new noflo.Port 'array'

    @inPorts.center.on 'data', (data) =>
      @arc[0] = data[0]
      @arc[1] = data[1]
      @compute()

    @inPorts.radius.on 'data', (data) =>
      @arc[2] = data
      @compute()

    @inPorts.start.on 'data', (data) =>
      @arc[3] = data
      @compute()

    @inPorts.end.on 'data', (data) =>
      @arc[4] = data
      @compute()

    @inPorts.reverse.on 'data', (data) =>
      @arc[5] = data
      @compute()

    @inPorts.arc.on 'data', (data) =>
      @arc[0] = data[0]
      @arc[1] = data[1]
      @arc[2] = data[2]
      @arc[3] = data[3]
      @arc[4] = data[4]
      @arc[5] = data[5]
      @compute()

  compute: ->
    if @outPorts.arc.isAttached() and @arc.indexOf(null) is -1
      @outPorts.arc.send @arc

exports.getComponent = -> new Arc
