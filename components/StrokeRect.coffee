noflo = require 'noflo'
{MakeCanvasPrimative} = require '../lib/MakeCanvasPrimative'

class StrokeRect extends MakeCanvasPrimative
  description: 'Strokes a rectangle'
  icon: 'pencil-square-o'
  constructor: ->
    ports =
      point:
        datatype: 'object'
        description: 'top left point'
      width:
        datatype: 'number'
      height:
        datatype: 'number'
    
    super 'strokeRect', ports    

  exports.getComponent = -> new StrokeRect
