noflo = require 'noflo'

class Clear extends noflo.Component
  description: 'Makes a clear rectangle with given dimensions'
  icon: 'eraser'
  constructor: ->
    @clear =
      type: 'clear'
      rectangle: null

    @inPorts =
      rectangle: new noflo.Port 'array'
    @outPorts =
      clear: new noflo.Port 'object'

    @inPorts.rectangle.on 'data', (data) =>
      @clear.rectangle = data
      if @outPorts.clear.isAttached()
        @outPorts.clear.send @clear


exports.getComponent = -> new Clear
