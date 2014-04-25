noflo = require 'noflo'

class LineWidth extends noflo.Component
  description: 'Sets the line width'
  icon: 'pencil-square'
  constructor: ->
    @linewidth =
      type: 'lineWidth'
      value: null

    @inPorts =
      width: new noflo.Port 'number'
    @outPorts =
      linewidth: new noflo.Port 'object'

    @inPorts.width.on 'data', (width) =>
      @linewidth.value = width
      if @outPorts.linewidth.isAttached()
        @outPorts.linewidth.send @linewidth

exports.getComponent = -> new LineWidth
