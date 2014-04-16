noflo = require 'noflo'

class Path extends noflo.Component
  description: 'Makes a path given a number of points, curves, etc'
  icon: 'pencil-square'
  constructor: ->
    @pathables = []
    @pathables.type = 'path'

    @inPorts =
      pathables: new noflo.ArrayPort 'array'

    @outPorts =
      path: new noflo.Port 'array'

    @inPorts.pathables.on 'data', (pathable, i) =>
      @pathables[i] = pathable
      if @outPorts.path.isAttached() and @pathables.indexOf(null) is -1
        @outPorts.path.send @pathables

    # TODO listen for detach / reindex

exports.getComponent = -> new Path
