noflo = require 'noflo'

class Stroke extends noflo.Component
  description: 'Paints the received polyline as a line'
  icon: 'pencil-square'
  constructor: ->
    @strokables = []
    
    @inPorts =
      strokables: new noflo.ArrayPort 'object'
    @outPorts =
      stroke: new noflo.Port 'object'

    @inPorts.strokables.on 'data', (strokable, i) =>
      @strokables[i] = strokable
      if @outPorts.stroke.isAttached()
        @outPorts.stroke.send {'stroke': @strokables}

    # TODO listen for detach / reindex

exports.getComponent = -> new Stroke
