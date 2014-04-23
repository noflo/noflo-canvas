noflo = require 'noflo'
{MakeCanvasPrimative} = require '../lib/MakeCanvasPrimative'

class Transform extends MakeCanvasPrimative
  description: 'Translate, rotate, and/or scale passed drawing commands.'
  icon: 'arrows'
  constructor: ->
    ports =
      items:
        datatype: 'object'
        description: 'fill and stroke commands to transform'
        addressable: true
      translate:
        datatype: 'object'
        type: 'noflo-canvas/point'
        description: 'translate by this vector'
        required: false
      scale:
        datatype: 'object'
        type: 'noflo-canvas/point'
        description: 'stretch or mirror'
        required: false
      scaleboth:
        datatype: 'number'
        description: 'scale both x and y'
        required: false
      rotate:
        datatype: 'number'
        type: 'noflo-canvas/angle'
        description: 'angle in radians'
        required: false

    super 'transform', ports

exports.getComponent = -> new Transform




###
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
      translate: new noflo.Port 'array'
      rotate: new noflo.Port 'number'
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

    @inPorts.rotate.description = 'in radians'

  compute: ->
    if @outPorts.transform.isAttached() and @transform.transformables.length > 0
      @outPorts.transform.send @transform


exports.getComponent = -> new Transform
###