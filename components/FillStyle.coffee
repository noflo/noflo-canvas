noflo = require 'noflo'

class FillStyle extends noflo.Component
  description: 'Sets the fill style'
  icon: 'pencil-square'
  constructor: ->
    @fillstyle =
      type: 'fillStyle'
      value: null

    @inPorts =
      color: new noflo.Port 'color'
    @outPorts =
      fillstyle: new noflo.Port 'object'

    @inPorts.color.on 'data', (color) =>
      @fillstyle.value = color
      if @outPorts.style.isAttached()
        @outPorts.style.send @fillstyle

exports.getComponent = -> new FillStyle
