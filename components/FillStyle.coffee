noflo = require 'noflo'

class FillStyle extends noflo.Component
  description: 'Sets the fill style'
  icon: 'pencil-square'
  constructor: ->
    @fillstyle =
      type: 'fillStyle'
      value: null

    @inPorts =
      style: new noflo.Port 'color'
    @outPorts =
      fillstyle: new noflo.Port 'object'

    @inPorts.style.on 'data', (data) =>
      @fillstyle.value = data
      if @outPorts.fillstyle.isAttached()
        @outPorts.fillstyle.send @fillstyle

exports.getComponent = -> new FillStyle
