noflo = require 'noflo'

class Fill extends noflo.Component
  description: 'Fills the received paths, rectangles, circles, and arcs'
  icon: 'square'
  constructor: ->
    @fill =
      type: 'fill'
      fillables: []
      fillStyle: null

    @inPorts =
      fillables: new noflo.ArrayPort 'array'
      fillstyle: new noflo.ArrayPort 'string'
    @outPorts =
      fill: new noflo.Port 'object'

    @inPorts.fillables.on 'data', (data, i) =>
      @fill.fillables[i] = data
      @compute()

    @inPorts.fillstyle.on 'data', (data) =>
      @fill.fillStyle = data
      @compute()

    # TODO listen for detach / reindex

  compute: ->
    if @outPorts.fill.isAttached() and @fill.fillables.length > 0
      @outPorts.fill.send @fill

exports.getComponent = -> new Fill
