noflo = require 'noflo'

class Clear extends noflo.Component
  description: 'Makes a clear rectangle with given dimensions'
  icon: 'pencil-square'
  constructor: ->
    @rectangle = null

    @inPorts =
      rectangle: new noflo.Port 'array'
    @outPorts =
      clear: new noflo.Port 'object'

    @inPorts.rectangle.on 'data', (data) =>
      @rectangle = data
      if @outPorts.clear.isAttached()
        @outPorts.clear.send {'clear': @rectangle}


exports.getComponent = -> new Clear
