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
        required: true
      width:
        datatype: 'number'
        required: true
      height:
        datatype: 'number'
        required: true
    
    super 'clearRect', ports

exports.getComponent = -> new ClearRect
