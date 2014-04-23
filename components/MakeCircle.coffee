noflo = require 'noflo'
{MakeCanvasPrimative} = require '../lib/MakeCanvasPrimative'

class MakeCircle extends MakeCanvasPrimative
  description: 'Creates a circle or circles'
  icon: 'circle-o'
  constructor: ->
    ports =
      center:
        datatype: 'object'
        type: 'noflo-canvas/point'
        description: 'center point'
      radius:
        datatype: 'number'

    super 'circle', ports

exports.getComponent = -> new MakeCircle
