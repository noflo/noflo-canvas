noflo = require 'noflo'

class Recurse extends noflo.Component
  description: 'Makes a translation recursive.'
  icon: 'retweet'
  constructor: ->
    @recurse =
      type: 'recurse'
      recursables: []
      count: null

    @inPorts =
      recursables: new noflo.ArrayPort 'object'
      count: new noflo.Port 'number'
    @outPorts =
      recurse: new noflo.Port 'object'

    @inPorts.recursables.on 'data', (data, i) =>
      @recurse.recursables[i] = data
      @compute()

    @inPorts.recursables.description = 'Only translate is recursable'

    @inPorts.count.on 'data', (data) =>
      @recurse.count = data
      @compute()

  compute: ->
    if @outPorts.recurse.isAttached() and @recurse.recursables.length > 0
      @outPorts.recurse.send @recurse


exports.getComponent = -> new Recurse
