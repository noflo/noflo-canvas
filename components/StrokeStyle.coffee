noflo = require 'noflo'

class StrokeStyle extends noflo.Component
  description: 'Sets the stroke style'
  icon: 'pencil-square'
  constructor: ->
    @color = null

    @inPorts =
      color: new noflo.Port 'string'
    @outPorts =
      style: new noflo.Port 'object'

    @inPorts.color.on 'data', (color) =>
      @color = color
      if @outPorts.style.isAttached()
        @outPorts.style.send {'strokeStyle': @color}

exports.getComponent = -> new StrokeStyle
