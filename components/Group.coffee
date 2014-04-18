noflo = require 'noflo'

class Group extends noflo.Component
  description: 'Group drawing commands.'
  icon: 'folder-o'
  constructor: ->
    @group = 
      type: 'group'
      groupables: []

    @inPorts =
      groupables: new noflo.ArrayPort 'array'
    @outPorts =
      group: new noflo.Port 'object'

    @inPorts.groupables.on 'data', (data, i) =>
      @group.groupables[i] = data
      if @outPorts.group.isAttached() and @group.groupables.length > 0
        @outPorts.group.send @group


exports.getComponent = -> new Group
