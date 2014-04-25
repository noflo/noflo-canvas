noflo = require 'noflo'

class FillRect extends noflo.Component
  description: 'Paints the given rectangle onto the canvas'
  icon: 'pencil-square'
  constructor: ->
    @fillrect =
      type: 'fillRect'
      rectangle: null
    
    @inPorts =
      rectangle: new noflo.Port 'array'

    @outPorts =
      fillrect: new noflo.Port 'object'

    @inPorts.rectangle.on 'data', (context) =>
      @fillrect.rectangle = context
      if @outPorts.fillrect.isAttached()
        @outPorts.fillrect.send @fillrect

  exports.getComponent = -> new FillRect
