noflo = require 'noflo'

class Draw extends noflo.Component
  description: 'Draws received drawing commands'
  icon: 'pencil-square'
  constructor: ->
    @every = false
    @canvas = null
    @context = null
    @commands = []
    
    @inPorts =
      tick: new noflo.Port 'bang'
      every: new noflo.Port 'boolean'
      canvas: new noflo.Port 'object'
      commands: new noflo.ArrayPort 'object'

    @outPorts =
      canvas: new noflo.Port 'object'

    @inPorts.tick.on 'data', (tick) =>
      if @context
        @parse @commands
        return
      @sendLog
        loglevel: 'error'
        message: 'Received commands but there is not 2d context attached.'

    @inPorts.every.on 'data', (data) =>
      @every = data

    @inPorts.canvas.on 'data', (canvas) =>
      @canvas = canvas
      @context = canvas.getContext('2d')
      
    @inPorts.commands.on 'data', (commands, i) =>
      @commands[i] = commands
      if @every
        @parse @commands


    # @inPorts.commands.on 'detach', (i) =>
    #   @commands.splice i, 1
    #   if @every
    #     @parse @commands


  parse: (commands) =>
    console.log commands
    return unless @context
    for command in commands
      continue unless command
      for instr, args of command
        if @[instr]?
          @[instr].apply @, [args]
    if @outPorts.canvas.isAttached()
      @outPorts.fill.send @canvas

  clear: (rectangle) =>
    if rectangle
      @context.clearRect.apply @context, rectangle
    else
      @context.clearRect.apply @context, [0, 0, @canvas.width, @canvas.height]

  stroke: (strokableThings) =>
    @context.beginPath()
    for thing in strokableThings
      continue unless thing and thing.type and @[thing.type]?
      @[thing.type].apply @, [thing]
    @context.stroke()

  strokeStyle: (color) =>
    @context.strokeStyle = color

  fill: (fillableThings) =>
    @context.beginPath()
    for thing in fillableThings
      continue unless thing and thing.type and @[thing.type]?
      @[thing.type].apply @, [thing]
    @context.fill()

  fillStyle: (color) =>
    @context.fillStyle = color

  path: (pathableThings) =>
    for thing, i in pathableThings
      continue unless thing and thing.type
      if thing.type is 'beziercurve'
        @context.bezierCurveTo.apply @context, thing
      else if thing.type is 'point'
        if i is 0
          @context.moveTo.apply @context, thing
        else
          @context.lineTo.apply @context, thing

  rectangle: (args) =>
    x = args[0]
    y = args[1]
    w = args[2]
    h = args[3]
    @context.moveTo x, y
    @context.lineTo x+w, y
    @context.lineTo x+w, y+h
    @context.lineTo x, y+h
    @context.lineTo x, y

  fillRect: (args) =>
    @context.fillRect.apply @context, args

  arc: (args) =>
    @context.arc.apply @context, args

  drawImage: (args) =>
    @context.drawImage.apply @context, args
                  
exports.getComponent = -> new Draw
