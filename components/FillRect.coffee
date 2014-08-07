noflo = require 'noflo'
{MakeCanvasPrimative} = require '../lib/MakeCanvasPrimative'

class FillRect extends MakeCanvasPrimative
  description: 'Fills a rectangle'
  icon: 'pencil-square'
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
    
    super 'fillRect', ports

  exports.getComponent = -> new FillRect
