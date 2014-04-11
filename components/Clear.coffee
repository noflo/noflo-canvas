noflo = require 'noflo'

class Clear extends noflo.Component
  description: 'Makes a clear rectangle with given dimensions'
  icon: 'pencil-square'
  constructor: ->
    @coords = null

    @inPorts =
      coords: new noflo.Port 'array'
    @outPorts =
      rectangle: new noflo.Port 'array'

    @inPorts.coords.on 'data', (data) =>
      @coords = data
      if @outPorts.rectangle.isAttached()
        @outPorts.rectangle.send {'clear': @coords}

    @outPorts.rectangle.on 'attach', =>
      if @coords is null
        @outPorts.rectangle.send {'clear': null}

exports.getComponent = -> new Clear
