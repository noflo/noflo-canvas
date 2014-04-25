noflo = require 'noflo'

class StrokeRect extends noflo.Component
  description: 'Paints the given rectangle onto the canvas'
  icon: 'pencil-square-o'
  constructor: ->
    @strokerect =
      type: 'strokeRect'
      rectangle: null
    
    @inPorts =
      rectangle: new noflo.Port 'array'

    @outPorts =
      strokerect: new noflo.Port 'object'

    @inPorts.rectangle.on 'data', (context) =>
      @strokerect.rectangle = context
      if @outPorts.strokerect.isAttached()
        @outPorts.strokerect.send @strokerect

  exports.getComponent = -> new StrokeRect
