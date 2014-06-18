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

    @outPorts = new noflo.OutPorts
      canvas:
        datatype: 'object'
        required: false

    @inPorts.tick.on 'data', (tick) =>
      if @context
        @parse @commands
        return
      @sendLog
        loglevel: 'error'
        message: 'Received commands but there is not 2d context attached.'

    @inPorts.tick.on 'begingroup', (group) =>
      @outPorts.canvas.beginGroup group
    @inPorts.tick.on 'endgroup', () =>
      @outPorts.canvas.endGroup()
    @inPorts.tick.on 'disconnect', () =>
      @outPorts.canvas.disconnect()


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
    @outPorts.canvas.send @canvas

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

  clearRect: (clearRect) =>
    x = clearRect.point.x
    y = clearRect.point.y
    w = clearRect.width
    h = clearRect.height
    @context.clearRect(x, y, w, h)

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

  bezierCurve: (curve) =>
    @context.bezierCurveTo(curve.control1.x, curve.control1.y, curve.control2.x, curve.control2.y, curve.end.x, curve.end.y)

  pathItem: (thing, i) =>
    # Handle arrays of points
    if thing instanceof Array
      for child, j in thing
        @pathItem child, j
      return
    if thing.type?
      switch thing.type
        when 'point'
          if i is 0
            @context.moveTo thing.x, thing.y
          else
            @context.lineTo thing.x, thing.y
        when 'beziercurve'
          @bezierCurve thing
        when 'arc'
          @arc thing

  path: (path) =>
    # Build the path
    for thing, i in path.items
      continue unless thing?
      @pathItem thing, i

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
    x = fillrect.point.x
    y = fillrect.point.y
    w = fillrect.width
    h = fillrect.height
    @context.fillRect x, y, w, h

  strokeRect: (strokerect) =>
    x = strokerect.point.x
    y = strokerect.point.y
    w = strokerect.width
    h = strokerect.height
    @context.strokeRect x, y, w, h

  arc: (arc) =>
    @context.arc(arc.center.x, arc.center.y, arc.radius, arc.start, arc.end, arc.reverse)

  circle: (circle) =>
    @context.arc(circle.center.x, circle.center.y, circle.radius, 0, TAU)

  drawimage: (drawimage) =>
    return unless drawimage.image?
    if drawimage.sourcerect? and drawimage.destrect?
      d = drawimage.destrect
      s = drawimage.sourcerect
      @context.drawImage drawimage.image, d.point.x, d.point.y, d.width, d.height, s.point.x, s.point.y, s.width, s.height
      return
    if drawimage.destrect?
      d = drawimage.destrect
      @context.drawImage drawimage.image, d.point.x, d.point.y, d.width, d.height
      return
    if drawimage.destpoint?
      p = drawimage.destpoint
      @context.drawImage drawimage.image, p.x, p.y
      return
    # Default
    @context.drawImage drawimage.image, 0, 0
                  
exports.getComponent = -> new Draw
