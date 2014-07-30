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
        required: true
      width:
        datatype: 'number'
        required: true
      height:
        datatype: 'number'
        required: true

    super 'rectangle', ports

exports.getComponent = -> new MakeRectangle
