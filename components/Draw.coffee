noflo = require 'noflo'

class Draw extends noflo.Component
  description: 'Draws received drawing commands'
  icon: 'pencil-square'
  constructor: ->
    @context = null
    @commands = null
    
    @inPorts =
      tick: new noflo.Port 'number'
      context: new noflo.Port 'object'
      commands: new noflo.Port 'array'

    @inPorts.tick.on 'data', (tick) =>
      if @context
        @parse @commands

    @inPorts.context.on 'data', (context) =>
      @context = context
      
    @inPorts.commands.on 'data', (commands) =>
      @commands = commands

  parse: (commands) =>
    for command, arguments of commands
      @[command].apply @, [arguments]

  clear: (rectangle) =>
    @context.clearRect.apply @context, rectangle

  stroke: (strokableThings) =>
    for thing, arguments of strokableThings
      @context.beginPath()
      @[thing].apply @, [[arguments]]
      @context.stroke()

  polyline: (vectors) =>
    for vector, i in vectors
      if i == 0
        @context.moveTo.apply @context, vector
      else
        @context.lineTo.apply @context, vector
      
exports.getComponent = -> new Draw
