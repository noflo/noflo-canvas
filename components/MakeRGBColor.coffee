noflo = require 'noflo'
{MakeCanvasPrimative} = require '../lib/MakeCanvasPrimative'

class MakeRGBColor extends MakeCanvasPrimative
  description: 'Creates RGA or RGBA color or colors'
  icon: 'tint'
  constructor: ->
    ports =
      red:
        datatype: 'int'
        description: 'from 0 to 255'
        required: true
      green:
        datatype: 'int'
        description: 'from 0 to 255'
        required: true
      blue:
        datatype: 'int'
        description: 'from 0 to 255'
        required: true
      alpha:
        datatype: 'number'
        description: 'optional, from 0 to 1.0'
        required: false

    super 'color', ports

  compute: ->
    return unless @outPorts.color.isAttached()
    return unless @props.red? and @props.green? and @props.blue?
    color = @props
    if (@props.red instanceof Array or @props.green instanceof Array or
    @props.blue instanceof Array or @props.alpha instanceof Array)
      color = @expandToArray @props
      color = color.map @colorToString
    else
      color = @colorToString @props
    @outPorts.color.send color

  colorToString: (color) ->
    console.log 'ha!'
    r = Math.round(color.red)
    g = Math.round(color.green)
    b = Math.round(color.blue)
    if color.alpha?
      a = color.alpha
      return "rgba(#{r}, #{g}, #{b}, #{a})"
    else
      return "rgb(#{r}, #{g}, #{b})"


exports.getComponent = -> new MakeRGBColor
