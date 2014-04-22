noflo = require 'noflo'

class MakePath extends noflo.Component
  description: 'Makes a path given a number of points, curves, etc'
  icon: 'star-o'
  constructor: ->
    @path =
      type: 'path'
      pathables: []

    @inPorts =
      pathables: new noflo.ArrayPort 'array'

    @outPorts =
      path: new noflo.Port 'array'

    @inPorts.pathables.on 'data', (pathable, i) =>
      @path.pathables[i] = pathable
      if @outPorts.path.isAttached()
        @outPorts.path.send @path

    # TODO listen for detach / reindex

exports.getComponent = -> new MakePath
