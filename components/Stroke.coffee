noflo = require 'noflo'

class Stroke extends noflo.Component
  description: 'Strokes the received paths, rectangles, circles, and arcs as lines'
  icon: 'square-o'
  constructor: ->
    @stroke =
      type: 'stroke'
      strokables: []
      strokeStyle: null
      lineWidth: null
    
    @inPorts =
      strokables: new noflo.ArrayPort 'array'
      strokestyle: new noflo.ArrayPort 'string'
      linewidth: new noflo.ArrayPort 'number'
    @outPorts =
      stroke: new noflo.Port 'object'

    @inPorts.strokables.on 'data', (data, i) =>
      @stroke.strokables[i] = data
      @compute()

    @inPorts.strokestyle.on 'data', (data) =>
      @stroke.strokeStyle = data
      @compute()

    @inPorts.linewidth.on 'data', (data) =>
      @stroke.lineWidth = data
      @compute()

    # TODO listen for detach / reindex

  compute: ->
    if @outPorts.stroke.isAttached() and @stroke.strokables.length > 0
      @outPorts.stroke.send @stroke

    # TODO listen for detach / reindex

exports.getComponent = -> new Stroke
