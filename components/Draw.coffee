noflo = require 'noflo'

TAU = Math.PI * 2

class Draw extends noflo.LoggingComponent
  description: 'Draws received drawing commands'
  icon: 'pencil'
  constructor: ->
    @drawevery = false
    @clearevery = false
    @canvas = null
    @context = null
    @commands = []
    
    @inPorts =
      tick: new noflo.Port 'bang'
      drawevery: new noflo.Port 'boolean'
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

    @inPorts.drawevery.on 'data', (data) =>
      @drawevery = data

    @inPorts.clearevery.on 'data', (data) =>
      @clearevery = data

    @inPorts.canvas.on 'data', (canvas) =>
      @canvas = canvas
      @context = canvas.getContext '2d'
      
    @inPorts.commands.on 'data', (commands, i) =>
      @commands[i] = commands
      if @drawevery
        @parse @commands


    # @inPorts.commands.on 'detach', (i) =>
    #   @commands.splice i, 1
    #   if @drawevery
    #     @parse @commands


  parse: (commands) =>
    return unless @context
    if @clearevery
      @context.clearRect 0, 0, @canvas.width, @canvas.height
    @parseThing commands
    if @outPorts.canvas.isAttached()
      @outPorts.fill.send @canvas

  # Recursively parse things and arrays of things
  parseThing: (thing, before, after) =>
    if thing? and thing.type? and @[thing.type]?
      if before?
        before()
      @[thing.type](thing)
      if after?
        after()
    else if thing instanceof Array
      for item in thing
        continue unless item?
        @parseThing item, before, after

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
    if stroke.strokestyle?
      oldStyle = @context.strokeStyle
      @context.strokeStyle = stroke.strokestyle
    if stroke.linewidth?
      oldWidth = @context.linewidth
      @context.lineWidth = stroke.linewidth
    # Stroke each thing
    before = ->
      @context.beginPath()
    after = ->
      if stroke.closepath
        @context.closePath()
      @context.stroke()
    @parseThing stroke.items, before.bind(@), after.bind(@)
    # Restore style
    if oldStyle?
      @context.strokeStyle = oldStyle
    if oldWidth?
      @context.lineWidth = oldWidth

  fill: (fill) =>
    # Cache current style
    if fill.fillstyle?
      oldStyle = @context.fillStyle
      @context.fillStyle = fill.fillstyle
    # Fill each thing
    before = ->
      @context.beginPath()
    after = ->
      @context.closePath()
      @context.fill()
    @parseThing fill.items, before.bind(@), after.bind(@)
    # Restore style
    if oldStyle?
      @context.fillStyle = oldStyle

  path: (path) =>
    # Build the path
    for thing, i in path.items
      continue unless thing? and thing.type?
      switch thing.type
        when 'point'
          if i is 0
            @context.moveTo thing.x, thing.y
          else
            @context.lineTo thing.x, thing.y
        when 'beziercurve'
          @context.bezierCurveTo(thing.control1.x, thing.control1.y,
            thing.control2.x, thing.control2.y, thing.end.x, thing.end.y)
        when 'arc'
          @arc thing

  group: (group) =>
    # Apply drawing operations
    for thing in group.groupables
      continue unless thing? and thing.type? and @[thing.type]?
      @[thing.type].call @, thing

  transform: (transform, recurse) =>
    # Apply transformations
    if transform.translate?
      @context.translate transform.translate.x, transform.translate.y
    if transform.rotate?
      @context.rotate transform.rotate
    if transform.scaleboth # non-zero
      @context.scale transform.scaleboth, transform.scaleboth
    else if transform.scale? and transform.scale.x and transform.scale.y # non-0
      @context.scale transform.scale.x, transform.scale.y
    # Apply drawing operations
    @parseThing transform.items
    # Recurse
    if recurse? and recurse > 0
      @transform transform, recurse-1
    # Undo transformations
    if transform.scaleboth # non-zero
      @context.scale 1/transform.scaleboth, 1/transform.scaleboth
    else if transform.scale? and transform.scale.x and transform.scale.y # non-0
      @context.scale 1/transform.scale.x, 1/transform.scale.y
    if transform.rotate?
      @context.rotate 0-transform.rotate
    if transform.translate?
      @context.translate 0-transform.translate.x, 0-transform.translate.y

  recurse: (recurse) =>
    for thing in recurse.recursables
      continue unless thing?
      if thing.type is 'transform'
        @transform thing, recurse.count

  rectangle: (rect) =>
    x = rect.point.x
    y = rect.point.y
    w = rect.width
    h = rect.height
    @context.moveTo x, y
    @context.lineTo x+w, y
    @context.lineTo x+w, y+h
    @context.lineTo x, y+h
    @context.lineTo x, y

  fillRect: (fillrect) =>
    @context.fillRect.apply @context, fillrect.rectangle

  strokeRect: (strokerect) =>
    @context.strokeRect.apply @context, strokerect.rectangle

  arc: (arc) =>
    @context.arc(arc.center.x, arc.center.y, arc.radius,
      arc.start, arc.end, arc.reverse)

  circle: (circle) =>
    @context.arc(circle.center.x, circle.center.y, circle.radius, 0, TAU)

  drawImage: (args) =>
    @context.drawImage.apply @context, args
                  
exports.getComponent = -> new Draw
