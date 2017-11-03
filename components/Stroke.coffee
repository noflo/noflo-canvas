noflo = require 'noflo'
ArrayableHelper = require 'noflo-helper-arrayable'

class Stroke extends noflo.Component
  description: 'Strokes lines for paths, rectangles, circles, and arcs'
  icon: 'square-o'
  constructor: ->
    super()
    ports =
      items:
        datatype: 'object'
        description: 'shapes (paths, circles, and rectangles) to stroke'
        addressable: true
        required: true
      strokestyle:
        datatype: 'string'
        description: 'css color string or canvas style'
        required: false
      linewidth:
        datatype: 'number'
        description: 'stroke width in pixels'
        required: false
      closepath:
        datatype: 'boolean'
        description: 'draw line back to start point'
        value: false

    ArrayableHelper @, 'stroke', ports

exports.getComponent = -> new Stroke
