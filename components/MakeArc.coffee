noflo = require 'noflo'
{MakeCanvasPrimative} = require '../lib/MakeCanvasPrimative'

class MakeArc extends MakeCanvasPrimative
  description: 'Creates an arc or arcs'
  icon: 'power-off'
  constructor: ->
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

    super 'arc', ports


exports.getComponent = -> new MakeArc
