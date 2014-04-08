noflo = require 'noflo'

class Get2dContext extends noflo.Component
  constructor: ->
    @inPorts =
      in: new noflo.Port
    @outPorts =
      out: new noflo.Port

    @inPorts.in.on "data", (data) =>
      console.log("HA!")

exports.getComponent = -> new Get2dContext
