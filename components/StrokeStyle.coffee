noflo = require 'noflo'

class StrokeStyle extends noflo.Component
  description: 'Sets the global stroke style'
  icon: 'pencil-square-o'
  constructor: ->
    @strokestyle =
      type: 'strokeStyle'
      value: null

    @inPorts =
      style: new noflo.Port 'string'
    @outPorts =
      strokestyle: new noflo.Port 'object'

    @inPorts.style.on 'data', (data) =>
      @strokestyle.value = data
      if @outPorts.strokestyle.isAttached()
        @outPorts.strokestyle.send @strokestyle

exports.getComponent = -> new StrokeStyle
