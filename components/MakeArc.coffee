noflo = require 'noflo'
ArrayableHelper = require 'noflo-helper-arrayable'

class MakeArc extends noflo.Component
  description: 'Creates an arc or arcs'
  icon: 'power-off'
  constructor: ->
    super()
    ports =
      center:
        datatype: 'object'
        description: 'point for center'
        required: true
      radius:
        datatype: 'number'
        required: true
      start:
        datatype: 'number'
        description: 'start angle in radians'
        required: true
      end:
        datatype: 'number'
        description: 'end angle in radians'
        required: true
      reverse:
        datatype: 'boolean'
        required: true
        default: false

    ArrayableHelper @, 'arc', ports

exports.getComponent = -> new MakeArc
