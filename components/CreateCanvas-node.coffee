# @runtime noflo-nodejs
# @name CreateCanvas

noflo = require 'noflo'
Canvas = require 'canvas'

class CreateCanvas extends noflo.Component
  description: 'Makes a Canvas with given dimensions'
  icon: 'pencil-square'
  constructor: ->
    @width = null
    @height = null

    @inPorts = new noflo.InPorts
      width:
        datatype: "int"
      height:
        datatype: "int"
    @outPorts = new noflo.OutPorts
      canvas:
        datatype: 'object'

    @inPorts.width.on 'data', (data) =>
      @width = data
      @create()

    @inPorts.height.on 'data', (data) =>
      @height = data
      @create()

  create: =>
    return unless @width>0 and @height>0
    canvas = new Canvas @width, @height
    if @outPorts.canvas.isAttached()
      @outPorts.canvas.send canvas

exports.getComponent = -> new CreateCanvas
