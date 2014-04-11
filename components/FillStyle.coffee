noflo = require 'noflo'

class FillStyle extends noflo.Component
  description: 'Sets the fill style'
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
        @outPorts.style.send {'fillStyle': @color}

exports.getComponent = -> new FillStyle
