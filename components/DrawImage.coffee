noflo = require 'noflo'
{MakeCanvasPrimative} = require '../lib/MakeCanvasPrimative'

class DrawImage extends MakeCanvasPrimative
  description: 'Draws the specified image'
  icon: 'pencil-square'
  constructor: ->
    ports =
      image:
        description: 'canvas, img, or video to draw'
        datatype: 'object'
        required: true
      destpoint:
        description: 'destination point (full size)'
        datatype: 'object'
        type: 'noflo-canvas/point'
        default:
          x: 0
          y: 0
        required: false
      destrect:
        description: 'destination rect, to scale'
        datatype: 'object'
        type: 'noflo-canvas/rectangle'
        required: false
      sourcerect:
        description: 'source rect, to scale'
        datatype: 'object'
        type: 'noflo-canvas/rectangle'
        required: false

    super 'drawimage', ports

exports.getComponent = -> new DrawImage
