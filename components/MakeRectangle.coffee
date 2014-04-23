noflo = require 'noflo'
{MakeCanvasPrimative} = require '../lib/MakeCanvasPrimative'

class MakeRectangle extends MakeCanvasPrimative
  description: 'Creates a rectangle or rectangles'
  icon: 'square-o'
  constructor: ->
    ports =
      point:
        datatype: 'object'
        description: 'top left point'
      width:
        datatype: 'number'
      height:
        datatype: 'number'

    super 'rectangle', ports

exports.getComponent = -> new MakeRectangle
