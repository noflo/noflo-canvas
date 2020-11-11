noflo = require 'noflo'

ctx = if noflo.isBrowser() then window.testutils = {} else exports

ctx.createCanvas = createCanvas = (width, height) ->
  if noflo.isBrowser()
    canvas = document.createElement 'canvas'
    canvas.width = width
    canvas.height = height
  else
    Canvas = require 'canvas'
    canvas = new Canvas.Canvas width, height
  return canvas
