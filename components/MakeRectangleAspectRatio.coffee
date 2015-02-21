noflo = require 'noflo'
{MakeCanvasPrimative} = require '../lib/MakeCanvasPrimative'

class MakeRectangleAspectRatio extends MakeCanvasPrimative
  description: 'Creates a rectangle, maintaining original aspect ratio'
  icon: 'square-o'
  constructor: ->
    ports =
      width:
        datatype: 'number'
        description: '<0 for dont-care'
        required: true
      height:
        datatype: 'number'
        description: '<0 for dont-care'
        required: true
      origwidth:
        datatype: 'number'
        description: 'from 0 to 100'
        required: true
      origheight:
        datatype: 'number'
        description: 'from 0 to 1.0'
        required: false

    super 'rectangle', ports

  hasAllProps: () ->
    @props.width? and @props.height? and @props.origwidth? and @props.origheight?

  # OVERRIDE default to make strings
  compute: ->
    return unless @outPorts.rectangle.isAttached()
    return unless @hasAllProps()
    inputs = @props
    out = @computeRectangle inputs
    out.type = 'rectangle'
    out.point = { type: 'point', x: 0, y: 0 }
    @outPorts.rectangle.send out

  computeRectangle: (inputs) ->
    aspectRatio = inputs.origheight / inputs.origwidth
    targetWidth = inputs.width
    targetHeight = inputs.height

    if targetWidth < 0 and targetHeight < 0
      # Pass through original
      targetWidth = inputs.origwidth
      targetHeight = inputs.origheight
    else if inputs.width < 0
      targetWidth = targetHeight/aspectRatio
    else if inputs.height < 0
      targetHeight = targetWidth*aspectRatio

    o =
      height: targetHeight
      width: targetWidth
    return o



exports.getComponent = -> new MakeRectangleAspectRatio
