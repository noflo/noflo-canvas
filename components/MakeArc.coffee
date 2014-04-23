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
      radius:
        datatype: 'number'
      start:
        datatype: 'number'
        description: 'start angle in radians'
      end:
        datatype: 'number'
        description: 'end angle in radians'
      reverse:
        datatype: 'boolean'
        value: false

    super 'arc', ports


exports.getComponent = -> new MakeArc
