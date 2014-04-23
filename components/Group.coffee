noflo = require 'noflo'

class Group extends noflo.Component
  description: 'Group drawing commands or primatives into a flattened array.'
  icon: 'folder-o'
  constructor: ->
    @group = []

    @inPorts =
      items: new noflo.ArrayPort 'object'
    @outPorts =
      group: new noflo.Port 'array'

    @inPorts.items.on 'data', (data, i) =>
      @group[i] = data
      if @outPorts.group.isAttached()
        # Flatten into one array
        g = []
        for child in @group
          if child instanceof Array
            for grandchild in child
              g.push grandchild
          else
            g.push child
        @outPorts.group.send g

    # @inPorts.items.on 'detach', (socket, i) =>
    #   console.log socket, i


exports.getComponent = -> new Group
