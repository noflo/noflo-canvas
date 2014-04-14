noflo = require 'noflo'

class Fill extends noflo.Component
  description: 'Paints the received polyline as a polygon'
  icon: 'pencil-square'
  constructor: ->
    @fillables = []

    @inPorts =
      fillables: new noflo.ArrayPort 'object'
    @outPorts =
      fill: new noflo.Port 'object'

    @inPorts.fillables.on 'data', (fillable, i) =>
      @fillables[i] = fillable
      if @outPorts.fill.isAttached()
        @outPorts.fill.send {'fill': @fillables}

    # TODO listen for detach / reindex

exports.getComponent = -> new Fill
