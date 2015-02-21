noflo = require 'noflo'
ArrayableHelper = require 'noflo-helper-arrayable'

class Fill extends noflo.Component
  description: 'Fills the received paths, rectangles, circles, and arcs'
  icon: 'square'
  constructor: ->
    ports =
      items:
        datatype: 'object'
        description: 'shapes (paths, circles, and rectangles) to fill'
        addressable: true
        required: true
      fillstyle:
        datatype: 'string'
        description: 'css color string'
        required: false

    ArrayableHelper @, 'fill', ports

exports.getComponent = -> new Fill
