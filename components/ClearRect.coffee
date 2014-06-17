noflo = require 'noflo'
{MakeCanvasPrimative} = require '../lib/MakeCanvasPrimative'

class ClearRect extends MakeCanvasPrimative
  description: 'Clear rectangle'
  icon: 'eraser'
  constructor: ->
    ports =
      point:
        datatype: 'object'
        description: 'top left point'
      width:
        datatype: 'number'
      height:
        datatype: 'number'
    
    super 'clearRect', ports

exports.getComponent = -> new ClearRect
