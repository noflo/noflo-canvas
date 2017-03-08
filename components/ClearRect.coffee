noflo = require 'noflo'
ArrayableHelper = require 'noflo-helper-arrayable'

class ClearRect extends noflo.Component
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
    
    ArrayableHelper @, 'clearrect', ports

exports.getComponent = -> new ClearRect
