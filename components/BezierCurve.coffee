noflo = require 'noflo'

class BezierCurve extends noflo.Component
  description: 'Creates an array of Points representing a Bezier curve'
  icon: 'pencil-square'
  constructor: ->
    @curve = []
    @curve[0] = null # control 1 x
    @curve[1] = null # control 1 y
    @curve[2] = null # control 2 x
    @curve[3] = null # control 2 y
    @curve[4] = null # end x
    @curve[5] = null # end y
    @curve.type = 'beziercurve'

    @inPorts =
      control1: new noflo.Port 'array'
      control2: new noflo.Port 'array'
      end: new noflo.Port 'array'
      curve: new noflo.Port 'array'

    @outPorts =
      curve: new noflo.Port 'array'

    @inPorts.control1.on 'data', (data) =>
      @curve[0] = data[0]
      @curve[1] = data[1]
      @compute()

    @inPorts.control2.on 'data', (data) =>
      @curve[2] = data[0]
      @curve[3] = data[1]
      @compute()

    @inPorts.end.on 'data', (data) =>
      @curve[4] = data[0]
      @curve[5] = data[1]
      @compute()

    @inPorts.circle.on 'data', (data) =>
      @curve[0] = data[0]
      @curve[1] = data[1]
      @curve[2] = data[2]
      @curve[3] = data[3]
      @curve[4] = data[4]
      @curve[5] = data[5]
      @compute()

  compute: ->
    if @outPorts.curve.isAttached() and @curve.indexOf(null) is -1
      @outPorts.curve.send @curve

exports.getComponent = -> new BezierCurve
