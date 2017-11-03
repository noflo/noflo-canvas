noflo = require 'noflo'
ArrayableHelper = require 'noflo-helper-arrayable'

class MakePoint extends noflo.Component
  description: 'Creates a point or points'
  icon: 'crosshairs'
  constructor: ->
    super()
    ports =
      x:
        datatype: 'number'
        required: true
      y:
        datatype: 'number'
        required: true

    ArrayableHelper @, 'point', ports

exports.getComponent = -> new MakePoint
