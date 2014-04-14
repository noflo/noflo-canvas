noflo = require 'noflo'

class Rectangle extends noflo.Component
  description: 'Creates a rectangle path'
  icon: 'pencil-square'
  constructor: ->
    @x = null
    @y = null
    @width = null
    @height = null

    @inPorts =
      x: new noflo.Port 'number'
      y: new noflo.Port 'number'
      width: new noflo.Port 'number'
      height: new noflo.Port 'number'
      rect: new noflo.Port 'array'

    @outPorts =
      rect: new noflo.Port 'array'

    @inPorts.x.on 'data', (data) =>
      @x = data
      @compute()

    @inPorts.y.on 'data', (data) =>
      @y = data
      @compute()

    @inPorts.width.on 'data', (data) =>
      @width = data
      @compute()

    @inPorts.height.on 'data', (data) =>
      @height = data
      @compute()

    @inPorts.rect.on 'data', (data) =>
      @x = data[0]
      @y = data[1]
      @width = data[2]
      @height = data[3]
      @compute()

  compute: ->
    if @outPorts.rect.isAttached() and @x? and @y? and @width? and @height?
      @outPorts.rect.send {"rectangle": [@x, @y, @width, @height]}

exports.getComponent = -> new Rectangle
