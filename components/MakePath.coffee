noflo = require 'noflo'
{MakeCanvasPrimative} = require '../lib/MakeCanvasPrimative'

class MakePath extends MakeCanvasPrimative
  description: 'Makes a path given a number of points, curves, etc'
  icon: 'star-o'
  constructor: ->
    ports =
      items:
        datatype: 'object'
        description: 'points, arcs, and curves to combine to make path'
        addressable: true

    super 'path', ports


exports.getComponent = -> new MakePath
