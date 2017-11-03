noflo = require 'noflo'
ArrayableHelper = require 'noflo-helper-arrayable'

class MakeRectangle extends noflo.Component
  description: 'Creates a rectangle or rectangles'
  icon: 'square-o'
  constructor: ->
    super()
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

    ArrayableHelper @, 'rectangle', ports

exports.getComponent = -> new MakeRectangle
