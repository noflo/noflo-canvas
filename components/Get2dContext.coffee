noflo = require 'noflo'

class Get2dContext extends noflo.Component
  description: 'Get 2D context from a DOM object'
  icon: 'pencil-square'
  constructor: ->
    @context = null

    @inPorts =
      element: new noflo.Port 'object'
    @outPorts =
      context: new noflo.Port 'object'

    @inPorts.element.on 'data', (element) =>
      @context = element.getContext('2d')
      if @outPorts.context.isAttached()
        @outPorts.context.send @context

exports.getComponent = -> new Get2dContext
