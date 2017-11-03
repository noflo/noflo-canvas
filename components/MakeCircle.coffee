noflo = require 'noflo'
ArrayableHelper = require 'noflo-helper-arrayable'

class MakeCircle extends noflo.Component
  description: 'Creates a circle or circles'
  icon: 'circle-o'
  constructor: ->
    super()
    ports =
      center:
        datatype: 'object'
        type: 'noflo-canvas/point'
        description: 'center point'
        required: true
      radius:
        datatype: 'number'
        required: true

    ArrayableHelper @, 'circle', ports

exports.getComponent = -> new MakeCircle
