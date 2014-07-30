noflo = require 'noflo'
{MakeCanvasPrimative} = require '../lib/MakeCanvasPrimative'

class MakePoint extends MakeCanvasPrimative
  description: 'Creates a point or points'
  icon: 'crosshairs'
  constructor: ->
    ports =
      x:
        datatype: 'number'
        required: true
      y:
        datatype: 'number'
        required: true

    super 'point', ports

exports.getComponent = -> new MakePoint
