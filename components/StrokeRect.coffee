noflo = require 'noflo'
ArrayableHelper = require 'noflo-helper-arrayable'

class StrokeRect extends noflo.Component
  description: 'Strokes a rectangle'
  icon: 'pencil-square-o'
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
    
    ArrayableHelper @, 'strokerect', ports

  exports.getComponent = -> new StrokeRect
