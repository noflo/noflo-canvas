noflo = require 'noflo'

class Draw extends noflo.Component
  description: 'Draws received drawing commands'
  icon: 'pencil'
  constructor: ->
    @every = false
    @clearevery = false
    @canvas = null
    @context = null
    @commands = []
    
    @inPorts =
      tick: new noflo.Port 'bang'
      every: new noflo.Port 'boolean'
      clearevery: new noflo.Port 'boolean'
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

    @inPorts.clearevery.on 'data', (data) =>
      @clearevery = data

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
    return unless @context
    if @clearevery
      @context.clearRect 0, 0, @canvas.width, @canvas.height
    for thing in commands
      continue unless thing? and thing.type? and @[thing.type]?
      @[thing.type].call @, thing
    if @outPorts.canvas.isAttached()
      @outPorts.fill.send @canvas

  clear: (clear) =>
    @context.clearRect.apply @context, clear.rectangle

  strokeStyle: (data) =>
    @context.strokeStyle = data.value

  lineWidth: (data) =>
    @context.lineWidth = data.value

  fillStyle: (data) =>
    @context.fillStyle = data.value

  stroke: (stroke) =>
    # Cache current style
    if stroke.strokeStyle?
      oldStyle = @context.strokeStyle
      @context.strokeStyle = stroke.strokeStyle
    if stroke.lineWidth?
      oldWidth = @context.lineWidth
      @context.lineWidth = stroke.lineWidth
    # Stroke each thing
    for thing in stroke.strokables
      continue unless thing?
      if thing.type? and @[thing.type]?
        @context.beginPath()
        @[thing.type].call @, thing
        if stroke.closePath
          @context.closePath()
        @context.stroke()
      else if !thing.type? and thing instanceof Array
        # deal with plain arrays
        for item in thing
          continue unless item? and item.type? and @[item.type]?
          @context.beginPath()
          @[item.type].call @, item
          if stroke.closePath
            @context.closePath()
          @context.stroke()
    # Restore style
    if oldStyle?
      @context.strokeStyle = oldStyle
    if oldWidth?
      @context.lineWidth = oldWidth

  fill: (fill) =>
    # Cache current style
    if fill.fillStyle?
      oldStyle = @context.fillStyle
      @context.fillStyle = fill.fillStyle
    # Fill each thing
    for thing in fill.fillables
      continue unless thing?
      if thing.type? and @[thing.type]?
        @context.beginPath()
        @[thing.type].call @, thing
        @context.closePath()
        @context.fill()
      else if !thing.type? and thing instanceof Array
        # deal with plain arrays
        for item in thing
          continue unless item? and item.type? and @[item.type]?
          @context.beginPath()
          @[item.type].call @, item
          @context.closePath()
          @context.fill()
    # Restore style
    if oldStyle?
      @context.fillStyle = oldStyle

  path: (path) =>
    # Build the path
    for thing, i in path.pathables
      continue unless thing? and thing.type?
      switch thing.type
        when 'point'
          if i is 0
            @context.moveTo.apply @context, thing
          else
            @context.lineTo.apply @context, thing
        when 'beziercurve'
          @context.bezierCurveTo.apply @context, thing
        when 'arc'
          @context.arc.apply @context, thing

  group: (group) =>
    # Apply drawing operations
    for thing in group.groupables
      continue unless thing? and thing.type? and @[thing.type]?
      @[thing.type].call @, thing

  transform: (transform, recurse) =>
    # Apply transformations
    if transform.translate?
      @context.translate.call @context, transform.translate[0], transform.translate[1]
    if transform.rotate?
      @context.rotate.call @context, transform.rotate
    if transform.scale?
      @context.scale.call @context, transform.scale[0], transform.scale[1]
    # Apply drawing operations
    for thing in transform.transformables
      continue unless thing? and thing.type? and @[thing.type]?
      @[thing.type].call @, thing
    # Recurse
    if recurse? and recurse > 0
      @transform transform, recurse-1
    # Undo transformations
    if transform.scale?
      @context.scale.call @context, 1/transform.scale[0], 1/transform.scale[1]
    if transform.rotate?
      @context.rotate.call @context, 0-transform.rotate
    if transform.translate?
      @context.translate.call @context, 0-transform.translate[0], 0-transform.translate[1]

  recurse: (recurse) =>
    for thing in recurse.recursables
      continue unless thing? 
      if thing.type is 'transform'
        @transform thing, recurse.count

  rectangle: (rect) =>
    x = rect[0]
    y = rect[1]
    w = rect[2]
    h = rect[3]
    @context.moveTo x, y
    @context.lineTo x+w, y
    @context.lineTo x+w, y+h
    @context.lineTo x, y+h
    @context.lineTo x, y

  fillRect: (fillrect) =>
    @context.fillRect.apply @context, fillrect.rectangle

  strokeRect: (strokerect) =>
    @context.strokeRect.apply @context, strokerect.rectangle

  arc: (args) =>
    @context.arc.apply @context, args

  drawImage: (args) =>
    @context.drawImage.apply @context, args
                  
exports.getComponent = -> new Draw
