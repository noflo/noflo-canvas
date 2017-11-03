noflo = require 'noflo'
ArrayableHelper = require 'noflo-helper-arrayable'

class MakeBezierCurve extends noflo.Component
  description: 'Creates a Bezier curve'
  icon: 'pencil-square'
  constructor: ->
    super()
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

    ArrayableHelper @, 'beziercurve', ports

exports.getComponent = -> new MakeBezierCurve
