noflo = require 'noflo'
{MakeCanvasPrimative} = require '../lib/MakeCanvasPrimative'

class MakeBezierCurve extends MakeCanvasPrimative
  description: 'Creates a Bezier curve'
  icon: 'pencil-square'
  constructor: ->
    ports =
      control1:
        datatype: 'object'
        type: 'noflo-canvas/point'
        description: 'control point 1'
        required: true
      control2:
        datatype: 'object'
        type: 'noflo-canvas/point'
        description: 'control point 2'
        required: true
      end:
        datatype: 'object'
        type: 'noflo-canvas/point'
        description: 'end point'
        required: true

    super 'beziercurve', ports

exports.getComponent = -> new MakeBezierCurve
