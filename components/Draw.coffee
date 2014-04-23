noflo = require 'noflo'

class Draw extends noflo.Component
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
      @context = canvas.getContext('2d')
      
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
    @parseArray commands
    if @outPorts.canvas.isAttached()
      @outPorts.fill.send @canvas

  parseArray: (arr) =>
    for thing in arr
      continue unless thing?
      if thing.type? and @[thing.type]?
        @[thing.type].call @, thing
      else if thing instanceof Array
        @parseArray thing

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
    if fill.fillstyle?
      oldStyle = @context.fillStyle
      @context.fillStyle = fill.fillstyle
    # Fill each thing
    for thing in fill.items
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
    for thing, i in path.items
      continue unless thing? and thing.type?
      switch thing.type
        when 'point'
          if i is 0
            @context.moveTo thing.x, thing.y
          else
            @context.lineTo thing.x, thing.y
        when 'beziercurve'
          @context.bezierCurveTo.apply @context, thing
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
    @context.arc(arc.center.x, arc.center.y, arc.radius, arc.start, arc.end, arc.reverse)

  drawImage: (args) =>
    @context.drawImage.apply @context, args
                  
exports.getComponent = -> new Draw
