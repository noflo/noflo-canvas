noflo = require 'noflo'

class StrokeStyle extends noflo.Component
  description: 'Sets the stroke style'
  icon: 'pencil-square'
  constructor: ->
    @strokestyle =
      type: 'strokeStyle'
      value: null

    @inPorts =
      color: new noflo.Port 'color'
    @outPorts =
      strokestyle: new noflo.Port 'object'

    @inPorts.color.on 'data', (color) =>
      @strokestyle.value = color
      if @outPorts.style.isAttached()
        @outPorts.style.send @strokestyle

exports.getComponent = -> new StrokeStyle
