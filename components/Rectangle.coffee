noflo = require 'noflo'

class Rectangle extends noflo.Component
  description: 'Creates an array representing a rectangle'
  icon: 'pencil-square'
  constructor: ->
    @rectangle = []
    @rectangle[0] = null # x
    @rectangle[1] = null # y
    @rectangle[2] = null # w
    @rectangle[3] = null # h
    @rectangle.type = 'rectangle'

    @inPorts =
      x: new noflo.Port 'number'
      y: new noflo.Port 'number'
      width: new noflo.Port 'number'
      height: new noflo.Port 'number'
      rectangle: new noflo.Port 'array'

    @outPorts =
      rectangle: new noflo.Port 'array'

    @inPorts.x.on 'data', (data) =>
      @rectangle[0] = data
      @compute()

    @inPorts.y.on 'data', (data) =>
      @rectangle[1] = data
      @compute()

    @inPorts.width.on 'data', (data) =>
      @rectangle[2] = data
      @compute()

    @inPorts.height.on 'data', (data) =>
      @rectangle[3] = data
      @compute()

    @inPorts.rectangle.on 'data', (data) =>
      @rectangle[0] = data[0]
      @rectangle[1] = data[1]
      @rectangle[2] = data[2]
      @rectangle[3] = data[3]
      @compute()

  compute: ->
    if @outPorts.rectangle.isAttached() and @rectangle.indexOf(null) is -1
      @outPorts.rectangle.send @rectangle

exports.getComponent = -> new Rectangle
