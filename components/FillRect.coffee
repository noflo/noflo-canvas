noflo = require 'noflo'
ArrayableHelper = require 'noflo-helper-arrayable'

class FillRect extends noflo.Component
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
    
    ArrayableHelper @, 'fillRect', ports

  exports.getComponent = -> new FillRect
