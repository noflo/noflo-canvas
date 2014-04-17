noflo = require 'noflo'

class Transform extends noflo.Component
  description: 'Translate, rotate, and/or scale passed drawing commands.'
  icon: 'arrows'
  constructor: ->
    @transform = 
      type: 'transform'
      transformables: []
      translate: null
      scale: null
      rotate: null

    @inPorts =
      transformables: new noflo.ArrayPort 'array'
      rotate: new noflo.Port 'number'
      translate: new noflo.Port 'array'
      scale: new noflo.Port 'array'
      scaleboth: new noflo.Port 'number'
    @outPorts =
      transform: new noflo.Port 'object'

    @inPorts.transformables.on 'data', (data, i) =>
      @transform.transformables[i] = data
      @compute()

    @inPorts.translate.on 'data', (data) =>
      return unless data[0]? and data[1]?
      @transform.translate = data
      @compute()

    @inPorts.scale.on 'data', (data) =>
      # Don't ever want 0
      return unless data[0] and data[1]
      @transform.scale = data
      @compute()

    @inPorts.scale.description = 'stretch or mirror'

    @inPorts.scaleboth.on 'data', (data) =>
      # Don't ever want 0
      @transform.scale = [data, data]
      @compute()

    @inPorts.scaleboth.description = 'x and y scale the same'

    @inPorts.rotate.on 'data', (data) =>
      @transform.rotate = data
      @compute()

  compute: ->
    if @outPorts.transform.isAttached() and @transform.transformables.length > 0
      @outPorts.transform.send @transform


exports.getComponent = -> new Transform
