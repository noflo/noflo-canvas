noflo = require 'noflo'
{MakeCanvasPrimative} = require '../lib/MakeCanvasPrimative'

typeIsArray = Array.isArray || ( value ) -> return Object.toString.call( value ) is '[object Array]'

class MakePath extends MakeCanvasPrimative
  description: 'Makes a path given a number of points, curves, etc'
  icon: 'star-o'
  constructor: ->
    ports =
      items:
        datatype: 'object'
        description: 'points, arcs, and curves to combine to make path'
        addressable: true
        required: true

    super 'path', ports

  # OVERRIDE, discussion at noflo/noflo-canvas#24
  compute: =>
    return unless @outPorts['path'].isAttached()
    out =
      type: 'path'
      items: []
    arrayCount = 0
    for item in @props.items
      unless item?
        # Short-circuit
        return
      if typeIsArray item
        arrayCount++

    if arrayCount is 0
      # eg. two points
      out.items = @props.items
    else if @props.items.length is 1 and arrayCount is 1
      # eg. one array of points
      out.items = @props.items[0]
    else
      # Multiple arrays, flatten combinations
      out.items = @expandToArray @props.items
      out = @expandToArray out

    if out
      @outPorts[@type].send out


exports.getComponent = -> new MakePath
