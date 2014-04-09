noflo = require 'noflo'

class FillRect extends noflo.Component
  description: 'Paints the given rectangle onto the canvas, using the current fill style'
  icon: 'pencil-square'
  constructor: ->
    @context = null
    @x = null
    @y = null
    @width = null
    @height = null
    
    @inPorts =
      context: new noflo.Port 'object'
      x: new noflo.Port 'number'
      y: new noflo.Port 'number'
      width: new noflo.Port 'number'
      height: new noflo.Port 'number'

    @outPorts =
      context: new noflo.Port 'object'

    @inPorts.context.on 'data', (context) =>
      @context = context
      @compute()
      
    @inPorts.x.on 'data', (x) =>
      @x = x
      @compute()
      
    @inPorts.y.on 'data', (y) =>
      @y = y
      @compute()
      
    @inPorts.width.on 'data', (width) =>
      @width = width
      @compute()
      
    @inPorts.height.on 'data', (height) =>
      @height = height
      @compute()
      
  compute: ->
    if @context? and @x? and @y? and @width? and @height?
      @context.fillStyle = '#ffffff'
      @context.fillRect(@x, @y, @width, @height)
      if @outPorts.context.isAttached()
        @outPorts.context.send @context

  exports.getComponent = -> new FillRect
