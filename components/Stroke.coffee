noflo = require 'noflo'
{MakeCanvasPrimative} = require '../lib/MakeCanvasPrimative'

class Stroke extends MakeCanvasPrimative
  description: 'Strokes lines for paths, rectangles, circles, and arcs'
  icon: 'square-o'
  constructor: ->
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

    super 'stroke', ports

exports.getComponent = -> new Stroke
